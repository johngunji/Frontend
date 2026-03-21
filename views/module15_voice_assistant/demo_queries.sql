select * from Patient;
select * from Visit;

insert into VoiceCommand (command_text)
values ('patients above 40');

call ExecuteCommand(1);

select command_id, command_text, execution_status, response_text
from VoiceCommand;

select * from ExecutionLog;

insert into VoiceCommand (command_text)
values ('show visits');

call ExecuteCommand(2);

select * from ExecutionLog;

select * from PatientsAbove40;
select * from PatientVisitSummary;
select * from CommandHistory;
select * from ExecutionDetails;