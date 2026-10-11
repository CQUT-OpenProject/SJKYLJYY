"""Execute labs 2–4 in separate databases; never overwrite existing databases."""
import json
import os
from pathlib import Path
import subprocess
from tasks import LABS, COUNTS, step

BASE=Path(__file__).resolve().parents[1]
MYSQL=os.environ.get('MYSQL_BIN','/opt/homebrew/opt/mysql@8.4/bin/mysql')
USER=os.environ.get('MYSQL_USER','root')
schema=(BASE/'common/schema.sql').read_text()
seed=(BASE/'common/sample_data.sql').read_text()
LABS[2][0]['steps']=[step(seed+'\n'+COUNTS,
    [['Category','3'],['Supplier','5'],['Student','5'],['Goods','4'],['SaleBill','6']])]


def execute(sql,database=None):
    args=[MYSQL,'--no-defaults','--default-character-set=utf8mb4',
          '--protocol=SOCKET','--batch','--raw','-u',USER]
    if database:
        args.append(database)
    p=subprocess.run(args,input=sql,text=True,capture_output=True)
    lines=p.stdout.splitlines()
    return dict(sql=sql,exit_code=p.returncode,stdout=p.stdout,stderr=p.stderr,
                columns=lines[0].split('\t') if lines else [],
                rows=[x.split('\t') for x in lines[1:]] if lines else [])


def validate(result,spec):
    error=spec['expected_error']
    if error:
        assert result['exit_code']!=0 and f'ERROR {error} ' in result['stderr'],result
    else:
        assert result['exit_code']==0,result
        if spec['expected_rows'] is not None:
            assert result['rows']==spec['expected_rows'],(result,spec['expected_rows'])
    result['expected_error']=error
    result['verified']=True


def log(path,results):
    path.write_text('\n\n'.join(
        f"SQL:\n{r['sql']}\nEXIT: {r['exit_code']}\n"
        f"STDOUT:\n{r['stdout']}STDERR:\n{r['stderr']}" for r in results))


def fingerprint():
    return execute("SELECT TABLE_NAME,COLUMN_NAME,COLUMN_TYPE,IS_NULLABLE,COLUMN_KEY "
                   "FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='SuperMarket' "
                   "ORDER BY TABLE_NAME,ORDINAL_POSITION;\n"+COUNTS,'SuperMarket')['stdout']


before=fingerprint()
for number in LABS:
    database=f'SuperMarket_EXP_{number}'
    exists=execute(f"SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='{database}';")
    assert exists['exit_code']==0,exists
    assert exists['rows']==[['0']],f'{database} exists; refusing to overwrite it.'


for number,tasks in LABS.items():
    database=f'SuperMarket_EXP_{number}'
    folder=BASE/f'EXP_1_{number}'
    out=folder/'results'
    out.mkdir(parents=True,exist_ok=True)
    (folder/'sql').mkdir(exist_ok=True)
    setup_sql=f'CREATE DATABASE {database} CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;\nUSE {database};\n'+schema
    if number!=2:
        setup_sql+='\n'+seed
    setup=execute(setup_sql)
    log(out/'setup.txt',[setup])
    assert setup['exit_code']==0,setup
    (folder/'sql/setup.sql').write_text(setup_sql)
    environment=execute('SELECT VERSION() AS version,CURRENT_DATE() AS execution_date,\n'
                        'YEAR(CURRENT_DATE()) AS age_reference_year,@@sql_mode AS sql_mode;',database)
    log(out/'environment.txt',[environment])
    report=dict(database=database,environment=environment,tasks=[],checks=[])
    allsql=f'USE {database};\n'

    def check(name,sql,rows=None,error=0):
        spec=step(sql,rows,error)
        result=execute(spec['sql'],database)
        log(out/f'check-{name}.txt',[result])
        validate(result,spec)
        report['checks'].append(dict(name=name,**result))
        print(f'PASS lab {number} check {name}',flush=True)

    for index,t in enumerate(tasks,1):
        results=[]
        task_sql=''
        for spec in t['steps']:
            if spec['expected_error']:
                task_sql+=f"-- Expected MySQL error {spec['expected_error']}\n"
            task_sql+=spec['sql']+'\n\n'
            result=execute(spec['sql'],database)
            results.append(result)
            log(out/f'task-{index:02}.txt',results)
            validate(result,spec)
        allsql+=f'\n-- TASK {index}: {t["title"]}\n'+task_sql
        report['tasks'].append(dict(number=index,title=t['title'],analysis=t['analysis'],results=results))
        print(f'PASS lab {number} task {index}',flush=True)
        if number==2 and index==4:
            check('category-key-migration',"""START TRANSACTION;
INSERT INTO Category SELECT 'CN004',CategoryName,Descriptions
FROM Category WHERE CategoryNO='CN005';
UPDATE Goods SET CategoryNO='CN004' WHERE CategoryNO='CN005';
DELETE FROM Category WHERE CategoryNO='CN005';
SELECT GoodsNO,CategoryNO FROM Goods WHERE GoodsNO='GN0007';
ROLLBACK;""",[['GN0007','CN004']])
            check('category-migration-rolled-back',
                  "SELECT CategoryNO FROM Goods WHERE GoodsNO='GN0007';",[['CN005']])
        if number==2 and index==8:
            check('old-product-child-rows-removed',
                  "SELECT COUNT(*) FROM SaleBill WHERE GoodsNO='GN0002';",[['0']])

    if number==3:
        inventory_fixture="""START TRANSACTION;
INSERT INTO Goods VALUES
('GNTEST1','sup001','CN001','库存测试一',1,2,3,'2026-10-11'),
('GNTEST2','sup001','CN001','库存测试二',1,2,9,'2026-10-11');
"""
        check('low-inventory-query',inventory_fixture+tasks[4]['steps'][0]['sql']+'\nROLLBACK;',[
              ['GNTEST1','sup001','库存测试一','3'],['GNTEST2','sup001','库存测试二','9']])
        check('inventory-two-column-sort',inventory_fixture+tasks[10]['steps'][0]['sql']+'\nROLLBACK;',[
              ['GNTEST2','库存测试二','CN001','9'],['GNTEST1','库存测试一','CN001','3']])
        check('age-range-positive',"""START TRANSACTION;
INSERT INTO Student VALUES
('STEST','年龄测试',YEAR(CURRENT_DATE())-23,NULL,'CS','IT','wxtest');
"""+tasks[7]['steps'][0]['sql']+'\nROLLBACK;', [['STEST','年龄测试','CS','IT','23']])
        sale_fixture="""START TRANSACTION;
INSERT INTO SaleBill VALUES ('GN0007','S04','2019-01-02',6);
"""
        check('year-having-positive',sale_fixture+tasks[17]['steps'][0]['sql']+'\nROLLBACK;', [['S04','6']])
        check('year-having-join-positive',sale_fixture+tasks[28]['steps'][0]['sql']+'\nROLLBACK;', [['闵红','ACC','6']])
        check('max-inventory-ties',"""START TRANSACTION;
INSERT INTO Goods VALUES
('GNTEST','sup001','CN001','并列测试',1,2,100,'2026-10-11');
"""+tasks[12]['steps'][0]['sql']+'\nROLLBACK;', [['GN0001','优乐美奶茶','100'],['GNTEST','并列测试','100']])
        check('sample-state-preserved',COUNTS,[['Category','3'],['Supplier','5'],['Student','5'],['Goods','4'],['SaleBill','6']])
    if number==4:
        check('join-view-update-positive',"""START TRANSACTION;
INSERT INTO Goods VALUES
('GNTEST','sup001','CN001','力神咖啡',5,8,1,'2026-10-11');
INSERT INTO SaleBill VALUES ('GNTEST','S01','2026-10-11',1);
UPDATE V_SSG SET SalePrice=10 WHERE GoodsName='力神咖啡';
SELECT SalePrice FROM Goods WHERE GoodsNO='GNTEST';
ROLLBACK;""",[['10.00']])
        check('join-view-fixture-rolled-back',
              "SELECT COUNT(*) FROM Goods WHERE GoodsNO='GNTEST';",[['0']])
        check('check-option-view-create',"CREATE VIEW V_MIS_CHECK AS SELECT * FROM Student WHERE Major='MIS' WITH CHECK OPTION;")
        check('check-option-rejects-it',"INSERT INTO V_MIS_CHECK (SNO,SName,BirthYear,College,Major,WeiXin) VALUES ('s11','检查测试',2000,'CS','IT','wx011');",error=1369)
        check('check-option-view-drop','DROP VIEW V_MIS_CHECK;')
        check('aggregate-view-update-rejected',"UPDATE V_COM SET StudentCount=10 WHERE College='CS';",error=1288)
        check('view-updatability-metadata',"SELECT TABLE_NAME,IS_UPDATABLE FROM information_schema.VIEWS WHERE TABLE_SCHEMA=DATABASE() ORDER BY TABLE_NAME;")
        check('final-student-state',"SELECT SNO,SName,Major FROM Student ORDER BY SNO;",[
            ['S01','李明','IT'],['S02','徐慧慧','MIS'],['S03','伍民','MIS'],
            ['S04','闵红','AC'],['S05','张小红','AC'],['s10','周瑜','IT']])
    final=execute(COUNTS,database)
    log(out/'final-state.txt',[final])
    assert final['exit_code']==0,final
    report['final_counts']=final['rows']
    (folder/'sql/experiment.sql').write_text(allsql)
    (out/'summary.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    dump=subprocess.run(['/opt/homebrew/opt/mysql@8.4/bin/mysqldump','--no-defaults','-u',USER,
                         '--set-gtid-purged=OFF','--skip-dump-date','--databases',database],text=True,capture_output=True)
    assert dump.returncode==0,dump.stderr
    (out/'final-state.sql').write_text(dump.stdout)

assert fingerprint()==before,'Experiment 1 was unexpectedly changed.'
print('Completed labs 2–4. Experiment 1 unchanged.',flush=True)
