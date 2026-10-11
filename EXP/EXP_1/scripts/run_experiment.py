"""Run the 15 DDL tasks and verify constraints against a real local MySQL.

Refuses to overwrite an existing SuperMarket database. All fixture DML is
transactional and rolled back; successful completion leaves five empty tables.
"""
import json
import os
from pathlib import Path
import re
import subprocess

BASE = Path(__file__).resolve().parents[1] / 'EXP_1_1'
MYSQL = os.environ.get('MYSQL_BIN', '/opt/homebrew/opt/mysql@8.4/bin/mysql')
USER = os.environ.get('MYSQL_USER', 'root')
OUT = BASE / 'results'
OUT.mkdir(exist_ok=True)


def mysql(sql, *, table=True, database=False):
    args = [MYSQL, '--no-defaults', '--default-character-set=utf8mb4',
            '--protocol=SOCKET', '-u', USER]
    args += ['--table', '--verbose', '--verbose', '--show-warnings'] if table else ['-N', '-B']
    if database:
        args += ['SuperMarket']
    return subprocess.run(args, input=sql, text=True, capture_output=True)


def require(condition, description):
    if not condition:
        raise RuntimeError(description)


def record(name, sql, result):
    (OUT / f'{name}.txt').write_text(
        sql + '\n\n' + result.stdout + result.stderr, encoding='utf-8')


exists = mysql("SELECT COUNT(*) FROM information_schema.SCHEMATA "
               "WHERE SCHEMA_NAME='SuperMarket';", table=False)
require(exists.returncode == 0, exists.stderr)
require(exists.stdout.strip() == '0', 'SuperMarket already exists; refusing to overwrite it.')
env_sql = 'SELECT VERSION(), @@version_comment, @@lower_case_table_names, @@sql_mode;'
env = mysql(env_sql)
record('environment', env_sql, env)
require(env.returncode == 0, env.stderr)
source = (BASE / 'sql/experiment.sql').read_text()
parts = re.split(r'^-- TASK (\d+)\s*$', source, flags=re.M)
sample = (BASE / 'sql/sample_data.sql').read_text()
results = {'tasks': [], 'checks': []}


def check(name, statement, expected_code=0, expected_text=None, fixture=True):
    sql = 'START TRANSACTION;\n' + (sample if fixture else '')
    sql += '\n' + statement + '\nROLLBACK;\n'
    result = mysql(sql, database=True)
    record(name, sql, result)
    if expected_code:
        require(result.returncode != 0 and f'ERROR {expected_code} ' in result.stderr,
                f'{name}: expected MySQL error {expected_code}, got {result.stderr}')
    else:
        require(result.returncode == 0, f'{name}: {result.stderr}')
        if expected_text:
            require(expected_text in result.stdout, f'{name}: missing {expected_text}')
    results['checks'].append({'name': name, 'expected_error': expected_code,
                              'exit_code': result.returncode, 'passed': True})
    print(f'PASS {name}', flush=True)


for n, block in zip(parts[1::2], parts[2::2]):
    sql = ('USE SuperMarket;\n' if n != '1' else '') + block.strip() + '\n'
    result = mysql(sql)
    record(f'task-{int(n):02}', sql, result)
    require(result.returncode == 0, f'Task {n}: {result.stderr}')
    results['tasks'].append({'number': int(n), 'exit_code': result.returncode})
    print(f'PASS task {n}', flush=True)
    if n == '3':
        check('unique-weixin-before-drop',
              "INSERT INTO Student VALUES ('T01','测试一',2000,'男','CS','IT','same');\n"
              "INSERT INTO Student VALUES ('T02','测试二',2000,'女','CS','IT','same');",
              1062, fixture=False)
    if n == '9':
        check('positive-check-zero-rejected',
              "UPDATE SaleBill SET Number=0 WHERE GoodsNO='GN0001' AND SNO='S01';", 3819)
    if n == '10':
        check('weixin-duplicate-after-drop',
              "UPDATE Student SET WeiXin='wx001' WHERE SNO='S02';\n"
              "SELECT IF(COUNT(*)=2,'DUPLICATE_ALLOWED','FAIL') AS result "
              "FROM Student WHERE WeiXin='wx001';",
              expected_text='DUPLICATE_ALLOWED')
    if n == '12':
        for value in [-1, 0, 100, 101]:
            check(f'range-boundary-{value}',
                  f"UPDATE SaleBill SET Number={value} WHERE GoodsNO='GN0001' AND SNO='S01';\n"
                  "SELECT Number FROM SaleBill WHERE GoodsNO='GN0001' AND SNO='S01';",
                  3819 if value in [-1, 101] else 0)

check('sample-data-counts',
      "SELECT 'Category' AS table_name, COUNT(*) AS rows_count FROM Category UNION ALL\n"
      "SELECT 'Supplier',COUNT(*) FROM Supplier UNION ALL\n"
      "SELECT 'Student',COUNT(*) FROM Student UNION ALL\n"
      "SELECT 'Goods',COUNT(*) FROM Goods UNION ALL\n"
      "SELECT 'SaleBill',COUNT(*) FROM SaleBill;\n"
      "SELECT GoodsNO,InPrice FROM Goods ORDER BY GoodsNO;\n"
      "SELECT IF((SELECT COUNT(*) FROM Category)=3 AND "
      "(SELECT COUNT(*) FROM Supplier)=5 AND (SELECT COUNT(*) FROM Student)=5 AND "
      "(SELECT COUNT(*) FROM Goods)=4 AND (SELECT COUNT(*) FROM SaleBill)=6, "
      "'SAMPLE_COUNTS_OK','FAIL') AS result;", expected_text='SAMPLE_COUNTS_OK')
check('primary-key-duplicate',
      "INSERT INTO Category VALUES ('CN001','重复类别','测试');", 1062)
check('salebill-composite-key-duplicate',
      "INSERT INTO SaleBill VALUES ('GN0001','S01','2026-10-10',1);", 1062)
check('goods-supplier-foreign-key',
      "UPDATE Goods SET SupplierNO='missing' WHERE GoodsNO='GN0001';", 1452)
check('goods-category-foreign-key',
      "UPDATE Goods SET CategoryNO='missing' WHERE GoodsNO='GN0001';", 1452)
check('salebill-goods-foreign-key',
      "UPDATE SaleBill SET GoodsNO='missing' WHERE GoodsNO='GN0001' AND SNO='S01';", 1452)
check('salebill-student-foreign-key',
      "UPDATE SaleBill SET SNO='missing' WHERE GoodsNO='GN0001' AND SNO='S01';", 1452)
check('referenced-parent-delete-rejected',
      "DELETE FROM Supplier WHERE SupplierNO='sup001';", 1451)
check('salebill-null-number-rejected',
      "UPDATE SaleBill SET Number=NULL WHERE GoodsNO='GN0001' AND SNO='S01';", 1048)
check('decimal-rounding',
      "UPDATE Goods SET InPrice=2.56 WHERE GoodsNO='GN0001';\n"
      "SELECT InPrice, IF(InPrice=2.6,'ROUNDING_OK','FAIL') AS result "
      "FROM Goods WHERE GoodsNO='GN0001';", expected_text='ROUNDING_OK')

final_sql = """
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA='SuperMarket'
ORDER BY TABLE_NAME, ORDINAL_POSITION;
SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM information_schema.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA='SuperMarket'
ORDER BY TABLE_NAME, CONSTRAINT_NAME;
SELECT TABLE_NAME, INDEX_NAME, NON_UNIQUE, SEQ_IN_INDEX, COLUMN_NAME, COLLATION
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA='SuperMarket' ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
SELECT 'Category' AS table_name, COUNT(*) AS rows_count FROM Category UNION ALL
SELECT 'Supplier',COUNT(*) FROM Supplier UNION ALL
SELECT 'Student',COUNT(*) FROM Student UNION ALL
SELECT 'Goods',COUNT(*) FROM Goods UNION ALL
SELECT 'SaleBill',COUNT(*) FROM SaleBill;
"""
final = mysql(final_sql, database=True)
record('final-schema', final_sql, final)
require(final.returncode == 0, final.stderr)
counts = mysql('SELECT (SELECT COUNT(*) FROM Category)+(SELECT COUNT(*) FROM Supplier)+'
               '(SELECT COUNT(*) FROM Student)+(SELECT COUNT(*) FROM Goods)+'
               '(SELECT COUNT(*) FROM SaleBill);', table=False, database=True)
require(counts.stdout.strip() == '0', 'Fixture data leaked outside transactions.')
results['fixture_rows_remaining'] = 0
(OUT / 'summary.json').write_text(json.dumps(results, ensure_ascii=False, indent=2) + '\n')
print(f'Finished: {len(results["tasks"])} tasks, {len(results["checks"])} checks; fixtures rolled back.')
