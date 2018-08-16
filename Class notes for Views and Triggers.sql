

---------------------------------------------------------------------------------------------------------

--Class Views and Triggers



--Views

Senerio 1
/*
The Sales Department would like to know how many Credit Cards
are expiring each month. 
The information is stored in the Sales.CreditCard
table but the Sales Department can’t see the Credit Card number. 
Create a View that includes all of the columns in the Sales.CreditCard 
table except the Credit Card Number. 
*/

Use AdventureWorks2012


Select	*
From	Sales.CreditCard

----------------------------------- drop view vw_CreditCardDetails

CREATE View 	vw_CreditCardDetails
AS
SELECT			CreditCardID,CardType,ExpMonth,ExpYear,ModifiedDate
FROM			[Sales].[CreditCard]

-----------------------------------

Select	*
From	vw_CreditCardDetails

Select	*
From	Sales.CreditCard

-------------

Select	*
From	vw_CreditCardDetails
Where	CardType like 'C%'

------------

Select		*
From		vw_CreditCardDetails
Where		CardType like 'C%' and ExpYear > 2007
order by	ExpYear

--------------------------------------
-- DML commmand on a view, will it effect the reference table?				YES. Whatever you do to either the VIEW or UNDERLYING 
																		--	table will b e affected

--Use Classroom
--Delete from Sample4
--Drop view vw_Sam

Insert into Sample4(Empid,EmpName,DeptId)
Select * 
From   [dbo].[Employee]

--

Select *
Into   Sample4
From   [dbo].[Employee]

Select * 
From   Sample4



	Create view vw_Sam
	AS
	Select EmpID,DeptID
	from   Sample4

	Select * from vw_Sam
	Select * from Sample4

	-- Lets update the view
	Update vw_Sam
	Set	   DeptID = 209
	Where  EmpID  = 3

	Select * from vw_Sam
	Select * from Sample4
------------------------------
	--Lets update the table
	Update Sample4
	Set	   DeptID = 27
	Where  EmpID  = 3

	Select * from Sample4
	Select * from vw_Sam
-------------------------------
	Insert Into vw_Sam
	values      (23,17)
	Select * from vw_Sam
	Select * from Sample4
	

-------------------------------

Delete 
from Sample4
Where Empid = 23

Select * from vw_Sam
	Select * from Sample4
	

--***** More about views can be found at http://www.w3schools.com/sql/sql_view.asp
--                                       http://www.dotnet-tricks.com/Tutorial/sqlserver/b4H8260312-Different-Types-of-SQL-Server-Views.html


-------------------------------------Class Example------------------------------------------------
/*

Using the table Sales.SalesOrderHeader from the AdventureWorks DB
Create a view that displays the CustomerId,AccountNumber and Orderdate

*****Business Requirements*****
The AccountNumber should not have the dashes

*/

SELECT		*
FROM		[Sales].[SalesOrderHeader]


ALTER VIEW 		vw_SalesOrderHeaderTest
AS
SELECT			CustomerID, REPLACE(AccountNumber, '-', ' ') as AccountNumber, OrderDate
FROM			[Sales].[SalesOrderHeader]


SELECT		*
FROM		vw_SalesOrderHeaderTest




---------------------------------------------------------------------------
---------------------------------------------------------------------------

--TRIGGERS
--Use Classroom


--Main Table
--Drop table Employee_Test
--Audit table
--Drop table Employee_Test_Audit



CREATE TABLE Employee_Test
(
Emp_ID INT Identity,
Emp_name Varchar(100),
Emp_Sal Decimal (10,2)
)

INSERT INTO Employee_Test VALUES ('Anees',1000);
INSERT INTO Employee_Test VALUES ('Rick',1200);
INSERT INTO Employee_Test VALUES ('John',1100);
INSERT INTO Employee_Test VALUES ('Stephen',1300);
INSERT INTO Employee_Test VALUES ('Maria',1400);

Select	*
From	Employee_Test


/*I will be creating an AFTER INSERT TRIGGER which will
 insert the rows inserted into the table into another audit table.
The main purpose of this audit table is to record the changes in the main table. 
This can be thought of as a generic audit trigger.*/ 


------Audit Table								


CREATE TABLE Employee_Test_Audit
(
Emp_ID int,
Emp_name varchar(100),
Emp_Sal decimal (10,2),
Audit_Action varchar(100),
Audit_Timestamp datetime
) 


Select	*
From	Employee_Test_Audit

-------Trigger placed on the Employee_Test table
/*(a) AFTER INSERT Trigger 
This trigger is fired after an INSERT on the table.
 Let’s create the trigger */ 



Create TRIGGER trgAfterInsert ON [dbo].[Employee_Test] 
FOR INSERT
AS
	declare @empid				int;
	declare @empname			varchar(100);
	declare @empsal				decimal(10,2);
	declare @audit_action		varchar(100);

	select @empid=i.Emp_ID		from inserted i;	
	select @empname=i.Emp_Name	from inserted i;	
	select @empsal=i.Emp_Sal	from inserted i;	
	set	   @audit_action=		'Inserted Record -- After Insert Trigger.';

	insert into Employee_Test_Audit (Emp_ID,Emp_Name,Emp_Sal,Audit_Action,Audit_Timestamp)       
	values							(@empid,@empname,@empsal,@audit_action,getdate());

	PRINT 'An insert trigger has fired, please see your DBA.'
--------------------------------------------------
/*
The CREATE TRIGGER statement is used to create the trigger.
THE ON clause specifies the table name on which the trigger is to be attached.
The FOR INSERT specifies that this is an AFTER INSERT trigger. 
In place of FOR INSERT, AFTER INSERT can be used. Both of them mean the same. 
In the trigger body, table named inserted has been used. This table is a logical
table and contains the row that has been inserted.

****More about logical tables at http://www.dotnet-tricks.com/Tutorial/sqlserver/7OT8250912-Inserted,-Deleted-Logical-table-in-SQL-Server.html
    These are tables automatically created during DML operations that are managed internally

I have selected the fields from
the logical inserted table from the row that has been inserted into different variables,
and finally inserted those values into the Audit table. 
To see the newly created trigger in action, lets insert a row into the main table as : 
*/

/*

How to see the data that is inserted
 
 Insert into one 
 Output Inserted.* 
 values      ('Nate',1),
             ('Ali',2)
*/
--------------------------------------------------

--Insert data into the Employee_Test table
insert into  Employee_Test 
values      ('Joe',5000)

--------------------------


Select	*
From	Employee_Test


Select	*
From	Employee_Test_Audit

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
/*
(b) AFTER UPDATE Trigger 
This trigger is fired after an update on the table. Let’s create the trigger as
*/

Create TRIGGER trgAfterUpdate ON [dbo].[Employee_Test]              --Same as Insert trigger except for Update and the If statement
FOR UPDATE
AS
	declare						@empid int;
	declare						@empname varchar(100);
	declare						@empsal decimal(10,2);
	declare						@audit_action varchar(100);

	select @empid=i.Emp_ID		from inserted i;	
	select @empname=i.Emp_Name	from inserted i;	
	select @empsal=i.Emp_Sal	from inserted i;	
	
	if update(Emp_Name)															
		set @audit_action=		'Updated Record -- After Update Trigger.';
	if update(Emp_Sal)
		set @audit_action=		'Updated Record -- After Update Trigger.';

	insert into Employee_Test_Audit(Emp_ID,Emp_Name,Emp_Sal,Audit_Action,Audit_Timestamp) 
	values      (@empid,@empname,@empsal,@audit_action,getdate());

	PRINT 'AFTER INSERT trigger fired.'
------------------------------------------

/*
The AFTER UPDATE Trigger is created in which the updated record is inserted into the audit table.
We can obtain the updated value
of a field from the update(column_name) function. In our trigger, we have used, if update(Emp_Name) 
to check if the column Emp_Name has been updated. We have similarly checked the column Emp_Sal for an update. 
Let’s update a record column and see what happens. 
*/
------------------------------


update	Employee_Test 
set		Emp_Sal=2500.00
where	Emp_ID=6



update	Employee_Test         ---Here there is no Emp_ID 7, will the trigger still fire?
set		Emp_Sal=18
where	Emp_ID=7
-------------------------------

Select	*
From	Employee_Test


Select	*
From	Employee_Test_Audit

---------------------------------------------------------------------------
---------------------------------------------------------------------------
/*
(c) AFTER DELETE Trigger
This trigger is fired after a delete on the table. Let’s create the trigger as:
*/


Create TRIGGER trgAfterDelete ON [dbo].[Employee_Test] 
AFTER DELETE											--	This will actually happen and show in the audit table
AS
	declare						@empid int;
	declare						@empname varchar(100);
	declare						@empsal decimal(10,2);
	declare						@audit_action varchar(100);

	select @empid=d.Emp_ID		from deleted d;	
	select @empname=d.Emp_Name	from deleted d;	
	select @empsal=d.Emp_Sal	from deleted d;	
	set    @audit_action=		'Deleted -- After Delete Trigger.';

	insert into Employee_Test_Audit (Emp_ID,Emp_Name,Emp_Sal,Audit_Action,Audit_Timestamp) 
	values							(@empid,@empname,@empsal,@audit_action,getdate());
	     						

	PRINT 'You have deleted a record, Please see the DBA.'
-----------------------------------------------
/*
In this trigger, the deleted record’s data is picked from the logical deleted
table and inserted into the audit table. 
Let’s fire a delete on the main table. 
*/
---------------
Delete  
From	Employee_Test 
Where	Emp_ID = 1

---------------

Select	*
From	Employee_Test


Select	*
From	Employee_Test_Audit

------------------------------------------------------------------------------------

-- Instead of Delete Trigger
/*
These can be used as an interceptor for anything that anyone tried to do on our table or view.
If you define an Instead Of trigger on a table for the Delete operation, they try to delete rows, 
and they will not actually get deleted (unless you issue another delete instruction from within the trigger)
INSTEAD OF TRIGGERS can be classified further into three types as:
They will be built the same as AFTER Triggers except they will use the keywords INSTEAD OF DELETE
*/

--Drop Trigger trgInsteadOfDelete
Create TRIGGER trgInsteadOfDelete ON [dbo].[Employee_Test]			-- this is common because it will not actually delete coz it doesn't actaully happen
Instead of Delete													-- instead of trigger doesnt allow you to delete but it will show on the audit table that the attempt was attempted
AS
	declare						@empid int;
	declare						@empname varchar(100);
	declare						@empsal decimal(10,2);
	declare						@audit_action varchar(100);

	

	select @empid=d.Emp_ID		from deleted d;	
	select @empname=d.Emp_Name	from deleted d;	
	select @empsal=d.Emp_Sal	from deleted d;	
	set    @audit_action=		'Instead of Trigger--No record was deleted.';

	
	insert into Employee_Test_Audit (Emp_ID,Emp_Name,Emp_Sal,Audit_Action,Audit_Timestamp) 
	values							(@empid,@empname,@empsal,@audit_action,getdate());


	PRINT 'You can not deleted a record, Please see the DBA for help.'
-------------------------------------------------------------------------------------------

Delete  
From	Employee_Test 
Where	Emp_ID = 5

---------------

Select	*
From	Employee_Test


Select	*
From	Employee_Test_Audit

	-- All the triggers can be enabled/disabled on the table using the statement

	Alter Table Employee_Test Disable Trigger All
	Alter Table Employee_Test Enable  Trigger All

	--Specific triggers can be enabled/disabled on the table using the statement

	Alter Table Employee_Test Disable  Trigger trgInsteadOfDelete
	Alter Table Employee_Test Enable   Trigger trgInsteadOfDelete




----------------------------------------------------------------------------------------
--Using a Case Statement																--ANSWER TO THE 1 OF THE QUESTIONS 


create view vw_salesInfo
as
select	a.SalesOrderID, b.OrderDate, c.[Group], c.SalesYTD, c.SalesLastYear,
		case
			when c.SalesYTD > c.SalesLastYear then 'Making Profit'	
			when c.SalesYTD < c.SalesLastYear then 'Not Making Profit'	
			when c.SalesYTD = c.SalesLastYear then 'Even'
		end as Profit
from		[Sales].[SalesOrderDetail] a
inner join	[Sales].[SalesOrderHeader] b
on			a.SalesOrderID = b.SalesOrderID
inner join	[Sales].[SalesTerritory] c
on			b.TerritoryID = c.TerritoryID

Select	*
From    vw_salesInfo


