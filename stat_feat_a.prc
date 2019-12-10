CREATE OR REPLACE PROCEDURE stat_feat_a (p_department_id   IN NUMBER,
                                         p_year            IN NUMBER,
                                         p_sem             IN varchar2)
IS
   --This is the statististics feature part a (3a and 3b) that needs to  be implemented.
   --Purpose is to simply print the enrollment statistics of students
   --pertaining to a departement.
   --we need to print the number of students enrolled in  a particular
   --course of the department_id we giving as input, corresponding to
   --year and semester.
   --dropped or wait listed cases are not to be counted in any courses in that year and semester in programs in the department.
   --Print out total number of courses in that department, year and semester, total number of course sections, of students enrolled and wait listed in each course section along with course id, course name, section id.

   ----------------------------------------------------------------------------------------------------------------------
   --This is 3a-----------------------------------------------------------------------------------------------------------
   CURSOR stu_stat
   IS
      SELECT s.*
        FROM department d,
             program p,
             course c,
             section se,
             student s
       WHERE     d.dept_id = 2
             AND p.dept_id = d.dept_id
             AND c.program_id = p.program_id
             AND se.course_id = c.course_id
             AND se.sem = p_sem
             AND se.year = p_year
             AND s.program_id = p.program_id
             AND s.course_id = c.course_id
             AND s.student_id NOT IN (SELECT student_id FROM waitlist);

   ------------------------------------------------------------------------------------------------------------------------------------
   --this is 3b-------------------------------------------------------------------------------------------------------------------------
   num_of_course      NUMBER; ---This variable will hold the number  of courses in  a department of the given  year and given sem
   num_of_sec         NUMBER; --This variable will hold the number of course sections pertaining to the course_id of the department_id
   num_of_stu_enrol   NUMBER; --This variable will hold the  number of students enrolled  in the section.
   num_of_stu         NUMBER;  -- The total number of students enrolled in the
BEGIN
     SELECT COUNT (course_id)
       INTO num_of_course
       FROM course
      WHERE     program_id IN (SELECT program_id
                                 FROM program
                                WHERE dept_id = p_department_id)
            AND course_id IN (SELECT course_id
                                FROM section
                               WHERE sem = p_sem AND year = p_year)
   GROUP BY course_id;

   SELECT COUNT (sec_id)
     INTO num_of_sec
     FROM section
    WHERE     course_id IN (SELECT course_id
                              FROM course
                             WHERE program_id IN (SELECT program_id
                                                    FROM program
                                                   WHERE dept_id =
                                                            p_department_id))
          AND sem = p_sem
          AND year = p_year;

     SELECT COUNT (s.student_id)
       INTO num_of_stu
       FROM department d,
            program p,
            course c,
            section se,
            student s
      WHERE     d.dept_id = 2
            AND p.dept_id = d.dept_id
            AND c.program_id = p.program_id
            AND se.course_id = c.course_id
            AND se.sem = 'Spring'
            AND se.year = 2019
            AND s.program_id = p.program_id
            AND s.course_id = c.course_id
            AND s.student_id NOT IN (SELECT student_id FROM waitlist)
   GROUP BY s.student_id;


   DBMS_OUTPUT.put_line (
         'The number  of courses in  a department of the given  year and given sem'
      || ' :-'
      || num_of_course);


   DBMS_OUTPUT.put_line (
         'The total number of course sections given  year and given sem are'
      || ' :-'
      || num_of_sec);

   DBMS_OUTPUT.put_line (
         'The total number of studens enrolled in the given departement and give  year and given sem are'
      || ' :-'
      || num_of_stu);



   FOR i IN stu_stat
   LOOP
      DBMS_OUTPUT.put_line (
            'The name of the students enrolled in the department given sem and year are'
         || ' :-'
         || i.student_name);
   END LOOP;
END stat_feat_a;