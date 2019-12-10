
CREATE OR REPLACE PACKAGE BODY course_scheduling_system
IS
   --------------------------------------------------------------------------
   -- Subject    : Backend code to create course scheduling system.
    FUNCTION Is_valid_courseid (p_course_id IN NUMBER)
      RETURN VARCHAR2
   IS
   BEGIN
      BEGIN                  -- To check the validity of the   input course_id
         IF (p_course_id = NULL)
         THEN
            DBMS_OUTPUT.Put_line ('Please provide a course_id');

            RETURN c_var;
         END IF;

         SELECT COUNT (course_id)
           INTO a1_var
           FROM course
          WHERE course_id = p_course_id;

         IF (a1_var != 1)
         THEN
            DBMS_OUTPUT.Put_line (
               p_course_id || ' :-' || 'this is an invalid course_id');

            RETURN c_var;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            DBMS_OUTPUT.Put_line (
               p_course_id || ' :-' || 'this is an invalid course_id');

            RETURN c_var;
      END;

      BEGIN
         --selecting the number of sections belonging to the input course_id
         SELECT num_secs
           INTO a_var
           FROM course
          WHERE course_id = p_course_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            DBMS_OUTPUT.Put_line (
                  p_course_id
               || ' :-'
               || 'this course_id has no number of sections defined');
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.Put_line (
               'An unexpected error has occured please raise with IT team');

            RETURN c_var;
      END;

      --selecting the current scheduled sections of the course belonging  to the input course_id
      BEGIN
           SELECT COUNT (sec_id)
             INTO b_var
             FROM schedule
            WHERE course_id = p_course_id
         GROUP BY course_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            DBMS_OUTPUT.Put_line (
               'Some unexpected error has occured please raise with IT team');
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.Put_line (
               'An unexpected error has occured please raise with IT team');
      END;

      --comparing the number of scheduled sections of the course with the number of sections of the course
      IF (a_var <= b_var)
      THEN
         DBMS_OUTPUT.Put_line (
               p_course_id
            || ' :-'
            || 'all the sections belonging to this course id are already scheduled');

         RETURN c_var;
      ELSE
         c_var := 'TRUE';

         b1_var := a_var - b_var;

         DBMS_OUTPUT.Put_line (
               p_course_id
            || ' :-'
            || 'For this course_id the number of sections that yet to be scheduled are'
            || '='
            || b1_var);

         RETURN c_var;
      END IF;
   END is_valid_courseid;

   PROCEDURE Course_assign (p_course_id      IN NUMBER,
                            p_course_year    IN NUMBER,
                            p_schedule_sem   IN VARCHAR2)
   IS
      CURSOR c1
      IS
         SELECT instruc_id, course_id
           FROM instruct_matrix
          WHERE course_id = p_course_id;

      --TYPE l_instruc_id IS TABLE OF teaching_preferences.instruc_id%TYPE;
      --TYPE l_course_id IS TABLE OF teaching_preferences.course_id%TYPE;
      --la_instruc_id l_instruc_id;
      --la_course_id  l_course_id;
      --inx1  PLS_INTEGER;
      l_var   NUMBER;
      t_var   NUMBER;
      d_var   VARCHAR2 (200);
   --stmt varchar2(2000);
   /*CURSOR fetch_instruct
      IS
         SELECT i.instruc_id,
                i.dept_id,
                p.program_id,
                p.p_type,
                c.course_id,
                c.num_secs,
                c.req_or_elec
           FROM instructors i,
                program p,
                course c,
                department d
          WHERE     i.dept_id = d.dept_id
                AND d.dept_id = p.dept_id
                AND p.program_id = c.program_id
                AND c.course_id = p_course_id;*/
   /* CURSOR fetch_unallot_secs IS
      SELECT *
      FROM   SECTION
      WHERE  course_id = p_course_id
             AND sec_id NOT IN (SELECT sec_id
                                FROM   schedule
                                WHERE  course_id = p_course_id); */
   BEGIN
      d_var := Is_valid_courseid (p_course_id);

      IF (d_var = 'TRUE')
      THEN
         --stmt := 'CREATE GLOBAL TEMPORARY table instruct_matrix(intruct_id number, course_id number, num_Section_preferences number, Num_courses_assigned number) ON COMMIT DELETE ROWS;';
         --execute immediate stmt;
         INSERT INTO instruct_matrix (instruc_id,
                                      course_id,
                                      num_section_preferences,
                                      num_courses_assigned)
            SELECT tp.instruc_id,
                   tp.course_id,
                   tp.num_section_preferences,
                   cl.num_courses_assigned
              FROM teaching_preferences tp, course_load cl
             WHERE     tp.instruc_id IN (SELECT i.instruc_id
                                           FROM instructors i,
                                                program p,
                                                course c,
                                                department d
                                          WHERE     i.dept_id = d.dept_id
                                                AND d.dept_id = p.dept_id
                                                AND p.program_id =
                                                       c.program_id
                                                AND c.course_id = p_course_id)
                   AND tp.course_id = p_course_id
                   AND tp.instruc_id = cl.instruc_id;

         --OPEN c1;
         --FETCH c1  INTO la_instruc_id, la_course_id;
         --CLOSE c1;
         FOR inx1 IN c1
         LOOP
              SELECT COUNT (instruc_id)
                INTO l_var
                FROM schedule
               WHERE instruc_id = inx1.instruc_id
            GROUP BY course_id;

            SELECT num_courses_assigned
              INTO t_var
              FROM course_load
             WHERE instruc_id = inx1.instruc_id;

            IF (l_var >= t_var)
            THEN
               DELETE FROM instruct_matrix
                     WHERE instruc_id = inx1.instruc_id;

               sort_instruc (p_course_id); -- Call here to insert into schedule
            END IF;
         END LOOP;
      END IF;
   END course_assign;

   ---------------------------------------------------------------------------------------------------------------------------------------
   PROCEDURE sort_instruc (p_course_id IN NUMBER)
   IS
      --This will sort the instruct_id;
      --TYPE l_instruc_id IS TABLE OF l_instruc_id.instruc_id%TYPE;
      --ins_id l_instruc_id
      --assign weights to instruct_ids the sorty
      --i pls_integer;
      --j pls_integer;
      sch_id                      NUMBER;
      l_num_Section_preferences   NUMBER;
      t2_var                      NUMBER;
      t_instruc_id                NUMBER;
      max_sch_id                  NUMBER;
      no_of_sec_willing           NUMBER;
      p_instruct_weight           NUMBER;

      CURSOR c2
      IS
         SELECT *
           FROM instruct_matrix
          WHERE course_id = p_course_id;


      CURSOR fetch_unallot_secs
      IS
         SELECT *
           FROM SECTION
          WHERE     course_id = p_course_id
                AND sec_id NOT IN (SELECT sec_id
                                     FROM schedule
                                    WHERE course_id = p_course_id);
   BEGIN
      BEGIN
         FOR i IN c2
         LOOP
            -- we want to assign the weights to instructors here.
            --suppose both instructor A and B need to teach two courses. A is assigned 1 course, and B is assigned nothing so far. Both A and B are willing to teach 2 sections of c. c has 3 unassigned sections. Now A's weight = min(2,3)*(2-1)=2, B's weight = min(2,3)*2=4. So the sort order is B, A.
            --This loop is to assign weights to the  instructors;
            SELECT num_section_preferences
              INTO l_num_section_preferences
              FROM instruct_matrix im
             WHERE im.instruc_id = i.instruc_id;

            SELECT num_courses_assigned
              INTO t2_var
              FROM course_load cl
             WHERE cl.instruc_id = i.instruc_id; -- This will hold the number of courses assigned to the instructor as of now.

            --b1_var -- global variable this was used to calculate the no of unassigned sections of the course.
            p_instruct_weight :=
               LEAST (l_num_section_preferences, b1_var) * (b1_var - t2_var);

            --/*A is assigned 1 course, and B is assigned nothing so far. Both A and B are willing to teach 2 sections of c. c
            -- has 3 unassigned sections. Now A's weight = min(2,3)*(2-1)=2, B's weight = min(2,3)*2=4. So the sort order is B, A. */

            INSERT INTO instruct_matrix (instruc_id, instruct_weight)
                 VALUES (i.instruc_id, p_instruct_weight);
         --We inserted weights now in our table.
         END LOOP;
      END;

      BEGIN
         FOR i IN c2
         LOOP
            --now lets assign the sections  to  the instructors--
            --the number of sections  that will be assigned to the instructor, is the minimal of unassigned sections of c and number of sections i is willing to teach.SELECT num_section_preferences
            SELECT num_section_preferences
              INTO l_num_section_preferences
              FROM instruct_matrix im
             WHERE im.instruc_id = i.instruc_id;

            no_of_sec_willing := LEAST (b1_var, l_num_section_preferences);

            IF (no_of_sec_willing > 0)
            THEN
               FOR j IN fetch_unallot_secs
               LOOP
                  SELECT MAX (schedule_id) INTO max_sch_id FROM schedule;

                  SELECT instruc_id
                    INTO t_instruc_id
                    FROM instruct_matrix
                   WHERE instruct_weight IN (SELECT MAX (instruct_weight)
                                               FROM instruct_matrix
                                              WHERE instruc_id = i.instruc_id);

                  max_sch_id := max_sch_id + 1;

                  ------------------------------------------------------------------------------------------------------------------------------------
                  assign_room (max_sch_id,
                               p_course_id,
                               j.sec_id,
                               t_instruc_id); ---this is to assign the room, and to make finak ebtries
               --into the schedule table.
               --------------------------------------------------------------------------------------------------------------------------------------

               END LOOP;
            END IF;
         END LOOP;
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (
               p_course_id
            || ' :-'
            || 'For this course_id the sorting algo has failed');
   END sort_instruc;

   -----------------------------------------------------------------------------------------------------------------------------------------
   PROCEDURE assign_room (p_schedule_id   IN NUMBER,
                          p_course_id     IN NUMBER,
                          p_sec_id        IN NUMBER,
                          p_instruc_id    IN NUMBER)
   IS
      --this procedure is 2.
      -- Assign room and time to a scheduled section. Input includes a schedule id. First check whether the schedule id is valid. If not print an error message. Next check whether the scheduled section already has a room and time block. If so print an error message saying that the course is already assigned. Otherwise find a room and a time block pair that satisfies the following conditions

      max_time_block_id   NUMBER;
      p_time_block_id     NUMBER;
      l_start_time        INTERVAL DAY TO SECOND;
      l_time_len          INTERVAL DAY TO SECOND;
      p_time_day          NUMBER;
      p_class_room_id     NUMBER;
      p_year_schedule     NUMBER;
      p_schedule_sem      VARCHAR2 (200);


      CURSOR c3
      IS
         SELECT *
           FROM schedule
          WHERE schedule_id = schedule_id;
   BEGIN
      SELECT time_block_id
        INTO p_time_block_id
        FROM schedule
       WHERE schedule_id = p_schedule_id;

      IF (p_time_block_id IS NOT NULL)
      THEN
         DBMS_OUTPUT.Put_line ('course is already assigned.');
      END IF;

      IF (p_time_block_id IS NULL)
      THEN
         FOR i IN c3
         LOOP
            SELECT MAX (time_block_id)
              INTO max_time_block_id
              FROM time_block
             WHERE course_id = i.course_id;

            SELECT start_time, time_len, time_day
              INTO l_start_time, l_time_len, p_time_day
              FROM time_block
             WHERE course_id = i.course_id;

            SELECT class_room_id INTO p_class_room_id FROM class_room;

            SELECT sems_spec_ins, year_spe_ins
              INTO p_schedule_sem, p_year_schedule
              FROM teaching_preferences
             WHERE instruc_id = p_instruc_id AND course_id = p_course_id;



            INSERT INTO schedule (schedule_id,
                                  course_id,
                                  sec_id,
                                  instruc_id,
                                  time_block_id,
                                  class_room_id,
                                  year_schedule,
                                  schedule_sem)
                 VALUES (p_schedule_id,
                         p_course_id,
                         p_sec_id,
                         p_instruc_id,
                         max_time_block_id,
                         p_class_room_id,
                         p_year_schedule,
                         p_schedule_sem);

            COMMIT;
         END LOOP;
      END IF;
   END assign_room;
-------------------------------------------------------------------------------------------------------------------------------------------
END course_scheduling_system;