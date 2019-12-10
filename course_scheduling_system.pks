CREATE OR REPLACE PACKAGE course_scheduling_system
IS
   --------------------------------------------------------------------------
   -- Subject    : Backend code to create course scheduling system.
   p_course_id         course.course_id%TYPE;
   a_var               NUMBER (10);
   a1_var              NUMBER (10);
   b_var               NUMBER (10);
   b1_var              NUMBER (10);
   c_var               VARCHAR2 (100) := 'FALSE';
   p_course_year       NUMBER (20);
   p_schedule_sem      VARCHAR2 (200);

   --TYPE instruct_weight IS TABLE OF NUMBER
   -- INDEX BY NUMBER;

   --l_instruct_weight   instruct_weight;

   --CREATE GLOBAL TEMPORARY table instruct_matrix(intruct_id number, course_id number, num_Section_preferences number, Num_courses_assigned number) ON COMMIT DELETE ROWS;
   ---------------------------------------------------------------------------
   FUNCTION Is_valid_courseid (p_course_id IN NUMBER)
      RETURN VARCHAR2;

   ----------------------------------------------------------------------------
   PROCEDURE course_assign (p_course_id      IN NUMBER,
                            p_course_year    IN NUMBER,
                            p_schedule_sem   IN VARCHAR2);

   -----------------------------------------------------------------------------
   PROCEDURE sort_instruc (p_course_id IN NUMBER);

   ------------------------------------------------------------------------------
   PROCEDURE assign_room (p_schedule_id   IN NUMBER,
                          p_course_id     IN NUMBER,
                          p_sec_id        IN NUMBER,
                          p_instruc_id    IN NUMBER);
------------------------------------------------------------------------------


END course_scheduling_system;