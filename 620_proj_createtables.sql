--------------------------------------------------------------------------
   -- Subject    : Backend DB objects to create course scheduling system.
   -- Copyright (c) Sukrit 
   -- Sukrit       12/04/2019   


drop table student cascade constraints;
drop table schedule cascade constraints;
drop table time_block cascade constraints;
drop table class_room cascade constraints;
drop table building cascade constraints;
drop table section cascade constraints;
drop table teaching_preferences cascade constraints;
drop table course_load cascade constraints;
drop table instructors cascade constraints;
drop table course cascade constraints;
drop table program cascade constraints;
drop table department cascade constraints;
drop table prerequisite cascade constraints;
drop table waitlist cascade constraints;
drop table special_permission cascade constraints;
drop table registration cascade constraints;



Create table department(
Dept_ID int,
Dept_Name varchar(30),
primary key(Dept_ID)
);

insert into Department values (1, 'Information Systems');
insert into Department values (2, 'Computer Science');
insert into Department values (3, 'Data Science');
insert into Department values (4, 'Cyber Security');
insert into Department values (5, 'Computer Engineering');



Create table program(
Program_ID int,
Dept_ID int,
P_name varchar(30),
P_Type number,
primary key(program_ID),
foreign key(Dept_ID) references department(dept_id)
);


insert into program values (11, 1, 'BS in Information Systems', 1);
insert into program values (12, 1, 'MS in Information Systems', 2);
insert into program values (13, 1, 'PhD in Information Systems', 3);
insert into program values (21, 2, 'BS in Computer Science', 1);
insert into program values (22, 2, 'MS in Computer Science', 2);
insert into program values (23, 2, 'PhD in Computer Science', 3);


Create table course(
course_ID int,
Program_ID int,
course_name varchar(30),
Credits number,
Grade_Format varchar(10),
num_secs number,
req_or_elec char,
prereq int,
room_type varchar(30),
primary key(course_ID),
foreign key(program_ID) references program(program_id),
foreign key(prereq) references course(course_ID)
);

insert into course values (121, 12, 'Advanced Database Projects', 3, 'P/F', 1, '1', null, 'regular');
insert into course values (122, 12, 'Decision support systems', 3, 'P/F', 1, '1', null, 'regular');
insert into course values (123, 12, 'Management Information Systems', 3, 'P/F', 1, '1', null, 'regular');
insert into course values (221, 22, 'Artificial Intelligence', 3, 'P/F', 2, '0', null, 'regular');
insert into course values (222, 22, 'Advanced Operating System', 3, 'P/F', 1, '1', null, 'regular');


Create table prerequisite(
Course_ID int,
prereq int,
foreign key(course_ID) references course(Course_ID),
foreign key(prereq) references course(Course_ID),
primary key(Course_ID,prereq)
);

insert into prerequisite values (121, 123);
insert into prerequisite values (221, 222);
insert into prerequisite values (122, 123);
insert into prerequisite values (221, 121);


Create table instructors(
instruc_id int,
dept_id int,
instruc_name varchar(30),
job_type varchar(20),
primary key(instruc_id),
foreign key(dept_id) references department(dept_id)
);

insert into instructors values (1001, 1,'Dr. Zhiyuan Chen', 'Full-time');
insert into instructors values (1002, 1, 'Dr. John Hebeler', 'Full-time');
insert into instructors values (1003, 1, 'Dr. Carlton Crabtree', 'Full-time');
insert into instructors values (2001, 2, 'Dr. Timothy Finn', 'Full-time');
insert into instructors values (2002, 2, 'Dr. Frank Ferraro', 'Full-time');

DROP TABLE course_load;

Create table course_load(
course_load_Id NUMBER,
instruc_id int,
Semester varchar(20),
Year number,
Num_courses_assigned number,
primary key (course_load_Id),
foreign key(instruc_id) references instructors(instruc_id)
);

insert into course_load values (course_load_Id_seq.nextval,1001, 'fall',2019,3);
insert into course_load values (course_load_Id_seq.nextval,1002, 'Spring',2019,2);
insert into course_load values (course_load_Id_seq.nextval,1003, 'Spring',2019,2);
insert into course_load values (course_load_Id_seq.nextval,2001, 'Summer',2019,4);
insert into course_load values (course_load_Id_seq.nextval,2002, 'Spring',2019,2);


Create table teaching_preferences(
Instruc_ID int,
Course_ID int,
num_Section_preferences number,--This is used to check whether intructor can take more sections or not.
Sems_spec_ins  varchar(20),
year_spe_ins number,
Cannot_Teach_days varchar(20),
foreign key(instruc_id) references instructors(instruc_id),
foreign key(course_id) references course(course_id),
primary key(instruc_id,course_id)
);

insert into teaching_preferences values (1001, 121,2, 'fall',2019,'Tuesday,thursday');
insert into teaching_preferences values (1002, 122,1, 'spring',2019,'Friday,thursday');
insert into teaching_preferences values (1003, 123,2, 'fall',2019,'Tuesday,thursday');
insert into teaching_preferences values (2001, 221,1, 'summer',2019,'monday,thursday');
insert into teaching_preferences values (2002, 222,2, 'fall',2019,'Sunday');


Create table section(
Sec_id int,
course_id int,
sem varchar(10),
year number,
section_size number,
status number,
primary key(sec_id),
foreign key(course_id) references course(course_id)
);

insert into section values (5001, 121, 'Fall', 2019, 50, 0);
insert into section values (5002, 122, 'Fall', 2019, 50, 0);
insert into section values (5003, 123, 'Fall', 2019, 50, 0);
insert into section values (5004, 221, 'Fall', 2019, 40, 1);
insert into section values (5005, 222, 'Fall', 2019, 50, 0);


Create table building(
B_ID int,
B_name varchar(30),
primary key(B_ID)
);

insert into building values (6001, 'Physics Building');
insert into building values (6002, 'Public Policy Building');
insert into building values (6003, 'University Center Building');
insert into building values (6004, 'Chemistry Building');
insert into building values (6005, 'Computer Science Building');

Create table class_room(
Class_room_id int,
B_id int,
room_name varchar(20),
num_seats number,
primary key(class_room_id),
foreign key(B_ID) references building(B_ID)
);


insert into class_room values (7001, 6001, 'Lecture Hall 1', 50);
insert into class_room values (7002, 6003, 'Conference Hall 1', 45);
insert into class_room values (7003, 6002, 'Lecture Hall 3', 50);
insert into class_room values (7054, 6005, 'Conference Hall 5', 45);
insert into class_room values (7055, 6004, 'Lecture Hall 7', 50);


Create table time_block(
time_block_id int,
course_id int,
start_time interval day to second,
time_len interval day to second,
time_day number,
primary key(time_block_id),
foreign key(course_id) references course(course_id)
);


insert into time_block values (8001, 121, interval '0 4:30:0.0' day to second, interval '0 2:30:0.0' day to second, 4);
insert into time_block values (8002, 122, interval '0 4:30:0.0' day to second, interval '0 2:30:0.0' day to second, 2);
insert into time_block values (8003, 123, interval '0 4:30:0.0' day to second, interval '0 2:30:0.0' day to second, 1);
insert into time_block values (8004, 221, interval '0 4:30:0.0' day to second, interval '0 2:30:0.0' day to second, 3);
insert into time_block values (8005, 222, interval '0 4:30:0.0' day to second, interval '0 0:30:0.0' day to second, 1);


create table schedule(
schedule_id int,
course_id int,
sec_id int,
instruc_id int,
time_block_id int,
class_room_id int,
year_schedule number,
schedule_sem varchar(10),
wait_list_cap number,
wait_list_status number,
sec_capacity number,
primary key(schedule_id),
foreign key(course_id) references course(course_id),
foreign key(sec_id) references section,
foreign key(instruc_id) references instructors(instruc_id),
foreign key(time_block_id) references time_block(time_block_id),
foreign key(class_room_id) references class_room(class_room_id)
);


insert into schedule values (6001, 121, 5001, 1001, 8001, 7001, 2019, 'Fall', 10, 0, 55);
insert into schedule values (6002, 122, 5002, 1002, 8002, 7002, 2019, 'Fall', 10, 0, 55);
insert into schedule values (6003, 123, 5003, 1003, 8003, 7003, 2019, 'Fall', 10, 0, 55);
insert into schedule values (6004, 221, 5004, 2001, 8004, 7054, 2019, 'Fall', 10, 1, 55);
insert into schedule values (6005, 222, 5005, 2002, 8005, 7055, 2019, 'Fall', 10, 0, 55);
insert into schedule values (6006, 123, 5003, 1003, 8003, 7003, 2018, 'Fall', 10, 0, 55);
insert into schedule values (6007, 221, 5004, 2001, 8004, 7054, 2018, 'Fall', 10, 1, 55);
insert into schedule values (6008, 222, 5005, 2002, 8005, 7055, 2018, 'Fall', 10, 0, 55);

create table student(
student_id int,
program_id int,
course_id int,
student_name varchar(20),
Grade number,
primary key(student_id),
foreign key(program_id) references program(program_id),
foreign key(course_id) references course(course_id)
);

insert into student values (1, 11, 121, 'John', 4);
insert into student values (2, 12, 122, 'Susan', 3);
insert into student values (3, 13, 123, 'Dave', 4);
insert into student values (4, 21, 221, 'Smith', 3);
insert into student values (5, 22, 222, 'Jane', 4);



create table waitlist(
student_id int,
schedule_id int,
waitlist_position number,
reg_status number,
special_permission_type number,
foreign key(student_id) references student(student_id),
foreign key(schedule_id) references schedule(schedule_id),
primary key(student_id,schedule_id)
);

insert into waitlist values (1, 6001, 1, 0, 1);
insert into waitlist values (2, 6002, 5, 0, null);
insert into waitlist values (3, 6003, 9, 0, null);
insert into waitlist values (4, 6004, 3, 0, 2);
insert into waitlist values (5, 6005, 7, 0, 2);

Create table registration(
Student_ID int,
Course_ID int,
reg_status int,
Foreign key(Student_ID) references Student(Student_ID),
Foreign key(Course_ID) references Course(course_ID),
Primary key(Student_ID,Course_ID)
);

insert into registration values (1, 121, 1);
insert into registration values (2, 121, 1);
insert into registration values (3, 121, 1);
insert into registration values (4, 123, 2);
insert into registration values (5, 122, 0);

Create table Special_permission(
Student_ID int,
Schedule_ID int,
Special_permission_type int,
Foreign Key(Student_ID) references Student(Student_ID),
Foreign Key(Schedule_ID) references Schedule(Schedule_ID),
Primary key(Student_ID, Schedule_ID)
);

insert into special_permission values (1, 6001, 1);
insert into special_permission values (2, 6002, 1);
insert into special_permission values (3, 6003, 2);
insert into special_permission values (4, 6003, 2);
insert into special_permission values (5, 6001, 1);


select * from department;
select * from program;
select * from course;
select * from instructors;
select * from section;
select * from building;
select * from class_room;
select * from time_block;
select * from schedule;
select * from student;
select * from waitlist;
select * from course_load;--course_load_id  inserted   via a sequence.
select * from teaching_preferences;
select * from registration;
select * from prerequisite;
select * from special_permission;


CREATE SEQUENCE course_load_Id_seq
start with 1
increment by 1
minvalue 0
maxvalue 1000000
nocycle;

CREATE GLOBAL TEMPORARY table instruct_matrix(instruc_id number, 
course_id number, num_Section_preferences number, Num_courses_assigned number,instruct_weight number) ON COMMIT DELETE ROWS;



