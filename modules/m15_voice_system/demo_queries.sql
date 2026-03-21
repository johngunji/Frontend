-- basic
CALL ExecuteCommand('show all patients');
CALL ExecuteCommand('show patient 1');
CALL ExecuteCommand('show female patients');
CALL ExecuteCommand('show male patients');
CALL ExecuteCommand('patients above 45');
CALL ExecuteCommand('patients below 40');

-- visits
CALL ExecuteCommand('show visits 1');
CALL ExecuteCommand('latest visit 1');
CALL ExecuteCommand('count visits 1');
CALL ExecuteCommand('history patient 1');

-- diagnosis
CALL ExecuteCommand('show diabetic patients');
CALL ExecuteCommand('show fever patients');
CALL ExecuteCommand('show asthma patients');
CALL ExecuteCommand('show cardiac patients');
CALL ExecuteCommand('show thyroid patients');
CALL ExecuteCommand('show migraine patients');

-- prescriptions
CALL ExecuteCommand('show prescriptions of patient 1');
CALL ExecuteCommand('show prescriptions of patient 3');

-- doctors
CALL ExecuteCommand('show all doctors');
CALL ExecuteCommand('show visits of doctor 1');

-- billing
CALL ExecuteCommand('show billing');
CALL ExecuteCommand('show pending bills');

-- time based
CALL ExecuteCommand('show todays visits');
CALL ExecuteCommand('show this month visits');

-- counts
CALL ExecuteCommand('count all patients');
CALL ExecuteCommand('count female patients');

-- error handling
CALL ExecuteCommand('delete patient 1');
CALL ExecuteCommand('what is the weather');
CALL ExecuteCommand('drop table patient');

-- views
select * from PatientVisitSummary;
select * from DiagnosisFrequency;
select * from CommandHistory;
select * from ExecutionDetails;

-- extra checks
select vc.command_text, ctx.context_type, ctx.context_value
from Context ctx
join VoiceCommand vc on ctx.command_id = vc.command_id
order by ctx.context_id desc;

select execution_status, count(*) as total
from VoiceCommand
group by execution_status;

select ct.template_pattern, count(*) as usage_count
from VoiceCommand vc
join CommandTemplate ct on vc.template_id = ct.template_id
group by ct.template_pattern
order by usage_count desc;
