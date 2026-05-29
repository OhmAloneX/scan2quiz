USE scan2quiz;

CREATE TABLE IF NOT EXISTS users (
  id            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  name          VARCHAR(100)    NOT NULL,
  email         VARCHAR(150)    NOT NULL,
  password_hash VARCHAR(255)    NOT NULL,
  role          ENUM('admin','teacher') NOT NULL DEFAULT 'teacher',
  is_active     TINYINT(1)      NOT NULL DEFAULT 1,
  last_login    DATETIME                 DEFAULT NULL,
  created_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS students (
  id            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  student_id    VARCHAR(30)     NOT NULL,
  name          VARCHAR(100)    NOT NULL,
  email         VARCHAR(150)             DEFAULT NULL,
  section       VARCHAR(50)              DEFAULT NULL,
  year_level    TINYINT UNSIGNED         DEFAULT NULL,
  barcode       VARCHAR(100)    NOT NULL,
  is_active     TINYINT(1)      NOT NULL DEFAULT 1,
  created_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_students_sid     (student_id),
  UNIQUE KEY uq_students_barcode (barcode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS quizzes (
  id            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  teacher_id    INT UNSIGNED    NOT NULL,
  title         VARCHAR(200)    NOT NULL,
  description   TEXT                     DEFAULT NULL,
  subject       VARCHAR(100)             DEFAULT NULL,
  time_limit    SMALLINT UNSIGNED        DEFAULT 30,
  passing_score DECIMAL(5,2)             DEFAULT 75.00,
  is_active     TINYINT(1)      NOT NULL DEFAULT 1,
  created_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_quizzes_teacher
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS questions (
  id            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  quiz_id       INT UNSIGNED    NOT NULL,
  question_text TEXT            NOT NULL,
  type          ENUM('multiple_choice','true_false','short_answer')
                                NOT NULL DEFAULT 'multiple_choice',
  points        TINYINT UNSIGNED NOT NULL DEFAULT 1,
  order_index   SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  created_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_questions_quiz
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS choices (
  id            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  question_id   INT UNSIGNED    NOT NULL,
  choice_text   VARCHAR(1000)   NOT NULL,
  is_correct    TINYINT(1)      NOT NULL DEFAULT 0,
  order_index   TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  CONSTRAINT fk_choices_question
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sessions (
  id            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  quiz_id       INT UNSIGNED    NOT NULL,
  teacher_id    INT UNSIGNED    NOT NULL,
  session_code  VARCHAR(10)     NOT NULL,
  qr_token      CHAR(36)        NOT NULL,
  qr_image      LONGTEXT                 DEFAULT NULL,
  status        ENUM('open','closed','graded') NOT NULL DEFAULT 'open',
  started_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  closed_at     DATETIME                 DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_sessions_code  (session_code),
  UNIQUE KEY uq_sessions_token (qr_token),
  CONSTRAINT fk_sessions_quiz
    FOREIGN KEY (quiz_id)    REFERENCES quizzes(id) ON DELETE CASCADE,
  CONSTRAINT fk_sessions_teacher
    FOREIGN KEY (teacher_id) REFERENCES users(id)   ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS attempts (
  id            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  session_id    INT UNSIGNED    NOT NULL,
  student_id    INT UNSIGNED    NOT NULL,
  score         DECIMAL(8,2)    NOT NULL DEFAULT 0,
  total_points  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  percentage    DECIMAL(5,2)    NOT NULL DEFAULT 0.00,
  passed        TINYINT(1)      NOT NULL DEFAULT 0,
  status        ENUM('in_progress','submitted','graded')
                                NOT NULL DEFAULT 'in_progress',
  started_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  submitted_at  DATETIME                 DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_attempts_session_student (session_id, student_id),
  CONSTRAINT fk_attempts_session
    FOREIGN KEY (session_id) REFERENCES sessions(id)  ON DELETE CASCADE,
  CONSTRAINT fk_attempts_student
    FOREIGN KEY (student_id) REFERENCES students(id)  ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS answers (
  id            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  attempt_id    INT UNSIGNED    NOT NULL,
  question_id   INT UNSIGNED    NOT NULL,
  choice_id     INT UNSIGNED             DEFAULT NULL,
  answer_text   TEXT                     DEFAULT NULL,
  is_correct    TINYINT(1)      NOT NULL DEFAULT 0,
  points_earned TINYINT UNSIGNED NOT NULL DEFAULT 0,
  answered_at   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_answers_attempt_question (attempt_id, question_id),
  CONSTRAINT fk_answers_attempt
    FOREIGN KEY (attempt_id)  REFERENCES attempts(id)  ON DELETE CASCADE,
  CONSTRAINT fk_answers_question
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
  CONSTRAINT fk_answers_choice
    FOREIGN KEY (choice_id)   REFERENCES choices(id)   ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


USE scan2quiz;

INSERT IGNORE INTO users (name, email, password_hash, role) VALUES
('Admin Teacher', 'admin@scan2quiz.com',
'$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
'admin'),
('Ms. Reyes', 'reyes@scan2quiz.com',
'$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
'teacher');

INSERT IGNORE INTO students (student_id, name, section, year_level, barcode)
VALUES
('2024-00001', 'Juan dela Cruz',  'BSCS 3-A', 3, 'BC2024001'),
('2024-00002', 'Maria Santos',    'BSCS 3-A', 3, 'BC2024002'),
('2024-00003', 'Pedro Reyes',     'BSCS 3-B', 3, 'BC2024003'),
('2024-00004', 'Ana Gonzales',    'BSIT 2-A', 2, 'BC2024004'),
('2024-00005', 'Carlo Mendoza',   'BSIT 2-A', 2, 'BC2024005');







USE scan2quiz;

-- Add status column to users table
ALTER TABLE users
ADD COLUMN IF NOT EXISTS status ENUM('pending','active','rejected')
NOT NULL DEFAULT 'active'
AFTER role;

-- Add approved_at timestamp
ALTER TABLE users
ADD COLUMN IF NOT EXISTS approved_at DATETIME DEFAULT NULL
AFTER status;

-- Update existing users to active
-- (so current admin/teacher accounts still work)
UPDATE users SET status = 'active'
WHERE status = 'active' OR status IS NULL;

-- ─────────────────────────────────────────────────────────────
-- Audit trail table (enterprise-style activity logging)
-- ─────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS audit_logs (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id       INT UNSIGNED DEFAULT NULL,
  role          ENUM('admin','teacher','student') DEFAULT NULL,
  action_type   VARCHAR(80) NOT NULL,
  module        VARCHAR(40) NOT NULL,
  description   VARCHAR(255) DEFAULT NULL,
  target_id     VARCHAR(64) DEFAULT NULL,
  target_type   VARCHAR(40) DEFAULT NULL,
  ip_address    VARCHAR(45) DEFAULT NULL,
  user_agent    VARCHAR(255) DEFAULT NULL,
  severity      ENUM('info','warning','critical') NOT NULL DEFAULT 'info',
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_audit_created_at (created_at),
  INDEX idx_audit_action_type (action_type),
  INDEX idx_audit_module_action_time (module, action_type, created_at),
  INDEX idx_audit_user_time (user_id, created_at),

  -- Optional FK: keep it nullable so unauthenticated events are allowed
  CONSTRAINT fk_audit_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ── STEP 2: SEED DATA ────────────────────────────────────────────
-- ============================================================
-- Scan2Quiz Massive Seed File
-- 100 Students | 100 Quizzes | 1000 Questions | 4000 Choices
-- ============================================================
USE scan2quiz;

-- ─── STUDENTS ────────────────────────────────────────────────
INSERT IGNORE INTO students (student_id, name, section, year_level, barcode) VALUES
  ('24-1-0101', 'Noreen Rivera', 'BSIT 1-A', 1, 'BC2410101'),
  ('24-1-0102', 'Ana Peralta', 'BSIT 1-A', 1, 'BC2410102'),
  ('24-1-0103', 'Aileen Morales', 'BSIT 1-A', 1, 'BC2410103'),
  ('24-1-0104', 'Gio Gomez', 'BSIT 1-A', 1, 'BC2410104'),
  ('24-1-0105', 'Wilfredo Flores', 'BSIT 1-A', 1, 'BC2410105'),
  ('24-1-0106', 'Cornelio Peralta', 'BSIT 1-A', 1, 'BC2410106'),
  ('24-1-0107', 'Cecile Torres', 'BSIT 1-A', 1, 'BC2410107'),
  ('24-1-0108', 'Richelle Diaz', 'BSIT 1-A', 1, 'BC2410108'),
  ('24-1-0109', 'Pedro Santos', 'BSIT 1-A', 1, 'BC2410109'),
  ('24-1-0110', 'Jenny Castillo', 'BSIT 1-A', 1, 'BC2410110'),
  ('24-1-0111', 'Erika Corpus', 'BSIT 1-A', 1, 'BC2410111'),
  ('24-1-0112', 'Katrina Santos', 'BSIT 1-A', 1, 'BC2410112'),
  ('24-1-0113', 'Rheya Lim', 'BSIT 1-A', 1, 'BC2410113'),
  ('24-1-0114', 'Carmela Crisostomo', 'BSIT 1-A', 1, 'BC2410114'),
  ('24-1-0115', 'Milagros Tolentino', 'BSIT 1-A', 1, 'BC2410115'),
  ('24-1-0201', 'Cherry Villanueva', 'BSIT 1-B', 1, 'BC2410201'),
  ('24-1-0202', 'Ivy Perez', 'BSIT 1-B', 1, 'BC2410202'),
  ('24-1-0203', 'Aileen dela Cruz', 'BSIT 1-B', 1, 'BC2410203'),
  ('24-1-0204', 'Anita Bautista', 'BSIT 1-B', 1, 'BC2410204'),
  ('24-1-0205', 'Milagros Diaz', 'BSIT 1-B', 1, 'BC2410205'),
  ('24-1-0206', 'Rowena Navarro', 'BSIT 1-B', 1, 'BC2410206'),
  ('24-1-0207', 'Lea Castillo', 'BSIT 1-B', 1, 'BC2410207'),
  ('24-1-0208', 'Anita Guevara', 'BSIT 1-B', 1, 'BC2410208'),
  ('24-1-0209', 'Grace Torres', 'BSIT 1-B', 1, 'BC2410209'),
  ('24-1-0210', 'Ramon Flores', 'BSIT 1-B', 1, 'BC2410210'),
  ('24-2-0101', 'Hazel Aguilar', 'BSIT 2-A', 2, 'BC2420101'),
  ('24-2-0102', 'Katrina Dela Torre', 'BSIT 2-A', 2, 'BC2420102'),
  ('24-2-0103', 'Remedios Reyes', 'BSIT 2-A', 2, 'BC2420103'),
  ('24-2-0104', 'Evangeline Hernandez', 'BSIT 2-A', 2, 'BC2420104'),
  ('24-2-0105', 'Jomar Rivera', 'BSIT 2-A', 2, 'BC2420105'),
  ('24-2-0106', 'Ramon Torres', 'BSIT 2-A', 2, 'BC2420106'),
  ('24-2-0107', 'Dante Soriano', 'BSIT 2-A', 2, 'BC2420107'),
  ('24-2-0108', 'Emmanuel Buenaventura', 'BSIT 2-A', 2, 'BC2420108'),
  ('24-2-0109', 'Patrick Sison', 'BSIT 2-A', 2, 'BC2420109'),
  ('24-2-0110', 'Christian Ilustre', 'BSIT 2-A', 2, 'BC2420110'),
  ('24-2-0111', 'Rico Reyes', 'BSIT 2-A', 2, 'BC2420111'),
  ('24-2-0112', 'Arsenio Villanueva', 'BSIT 2-A', 2, 'BC2420112'),
  ('24-2-0113', 'Leonardo Soriano', 'BSIT 2-A', 2, 'BC2420113'),
  ('24-2-0114', 'Mark Villanueva', 'BSIT 2-A', 2, 'BC2420114'),
  ('24-2-0115', 'Paul Salazar', 'BSIT 2-A', 2, 'BC2420115'),
  ('24-2-0201', 'Aileen Hernandez', 'BSIT 2-B', 2, 'BC2420201'),
  ('24-2-0202', 'Noreen Pascual', 'BSIT 2-B', 2, 'BC2420202'),
  ('24-2-0203', 'Bryan Pascual', 'BSIT 2-B', 2, 'BC2420203'),
  ('24-2-0204', 'Hazel Castillo', 'BSIT 2-B', 2, 'BC2420204'),
  ('24-2-0205', 'Florentina Navarro', 'BSIT 2-B', 2, 'BC2420205'),
  ('24-2-0206', 'Milagros Macaraig', 'BSIT 2-B', 2, 'BC2420206'),
  ('24-2-0207', 'Rogelio Mendoza', 'BSIT 2-B', 2, 'BC2420207'),
  ('24-2-0208', 'Katrina Magsaysay', 'BSIT 2-B', 2, 'BC2420208'),
  ('24-2-0209', 'Carla Tolentino', 'BSIT 2-B', 2, 'BC2420209'),
  ('24-2-0210', 'Evangeline Morales', 'BSIT 2-B', 2, 'BC2420210'),
  ('24-3-0101', 'Bryan Hernandez', 'BSIT 3-A', 3, 'BC2430101'),
  ('24-3-0102', 'Ramon Navarro', 'BSIT 3-A', 3, 'BC2430102'),
  ('24-3-0103', 'Noreen Roxas', 'BSIT 3-A', 3, 'BC2430103'),
  ('24-3-0104', 'Rheya Villanueva', 'BSIT 3-A', 3, 'BC2430104'),
  ('24-3-0105', 'Esperanza Bernardo', 'BSIT 3-A', 3, 'BC2430105'),
  ('24-3-0106', 'Leonardo Legarda', 'BSIT 3-A', 3, 'BC2430106'),
  ('24-3-0107', 'Liza Villanueva', 'BSIT 3-A', 3, 'BC2430107'),
  ('24-3-0108', 'Pedro Bernardo', 'BSIT 3-A', 3, 'BC2430108'),
  ('24-3-0109', 'Charm Navarro', 'BSIT 3-A', 3, 'BC2430109'),
  ('24-3-0110', 'Rico Castillo', 'BSIT 3-A', 3, 'BC2430110'),
  ('24-3-0111', 'Edwin Ilustre', 'BSIT 3-A', 3, 'BC2430111'),
  ('24-3-0112', 'Alvin Castillo', 'BSIT 3-A', 3, 'BC2430112'),
  ('24-3-0113', 'Maricel Delos Reyes', 'BSIT 3-A', 3, 'BC2430113'),
  ('24-3-0114', 'Ronaldo Crisostomo', 'BSIT 3-A', 3, 'BC2430114'),
  ('24-3-0115', 'Adrian Aquino', 'BSIT 3-A', 3, 'BC2430115'),
  ('24-3-0201', 'Gina Gomez', 'BSIT 3-B', 3, 'BC2430201'),
  ('24-3-0202', 'Trisha Peralta', 'BSIT 3-B', 3, 'BC2430202'),
  ('24-3-0203', 'Rheya Tolentino', 'BSIT 3-B', 3, 'BC2430203'),
  ('24-3-0204', 'Gina Peralta', 'BSIT 3-B', 3, 'BC2430204'),
  ('24-3-0205', 'Vincent Diaz', 'BSIT 3-B', 3, 'BC2430205'),
  ('24-3-0206', 'Vincent Ocampo', 'BSIT 3-B', 3, 'BC2430206'),
  ('24-3-0207', 'Patrick Villanueva', 'BSIT 3-B', 3, 'BC2430207'),
  ('24-3-0208', 'Donna Corpus', 'BSIT 3-B', 3, 'BC2430208'),
  ('24-3-0209', 'Verna Torres', 'BSIT 3-B', 3, 'BC2430209'),
  ('24-3-0210', 'Narciso Garcia', 'BSIT 3-B', 3, 'BC2430210'),
  ('24-4-0101', 'Kevin Aquino', 'BSIT 4-A', 4, 'BC2440101'),
  ('24-4-0102', 'Emmanuel Bautista', 'BSIT 4-A', 4, 'BC2440102'),
  ('24-4-0103', 'Natividad Macaraig', 'BSIT 4-A', 4, 'BC2440103'),
  ('24-4-0104', 'Stephen Macaraeg', 'BSIT 4-A', 4, 'BC2440104'),
  ('24-4-0105', 'Rico Salazar', 'BSIT 4-A', 4, 'BC2440105'),
  ('24-4-0106', 'Ramon Macaraeg', 'BSIT 4-A', 4, 'BC2440106'),
  ('24-4-0107', 'Hannah Ferrer', 'BSIT 4-A', 4, 'BC2440107'),
  ('24-4-0108', 'Jonel Evangelista', 'BSIT 4-A', 4, 'BC2440108'),
  ('24-4-0109', 'Maria Macaraig', 'BSIT 4-A', 4, 'BC2440109'),
  ('24-4-0110', 'Renato Rivera', 'BSIT 4-A', 4, 'BC2440110'),
  ('24-4-0111', 'Esperanza Tolentino', 'BSIT 4-A', 4, 'BC2440111'),
  ('24-4-0112', 'Narciso Navarro', 'BSIT 4-A', 4, 'BC2440112'),
  ('24-4-0113', 'Leonardo Crisostomo', 'BSIT 4-A', 4, 'BC2440113'),
  ('24-4-0114', 'Rowena Rivera', 'BSIT 4-A', 4, 'BC2440114'),
  ('24-4-0115', 'Shiela Diaz', 'BSIT 4-A', 4, 'BC2440115'),
  ('24-4-0201', 'Juan Espiritu', 'BSIT 4-B', 4, 'BC2440201'),
  ('24-4-0202', 'Renato Dela Torre', 'BSIT 4-B', 4, 'BC2440202'),
  ('24-4-0203', 'Francis Camacho', 'BSIT 4-B', 4, 'BC2440203'),
  ('24-4-0204', 'James Corpus', 'BSIT 4-B', 4, 'BC2440204'),
  ('24-4-0205', 'Grace Magsaysay', 'BSIT 4-B', 4, 'BC2440205'),
  ('24-4-0206', 'Ronel Magsaysay', 'BSIT 4-B', 4, 'BC2440206'),
  ('24-4-0207', 'Francis Macaraeg', 'BSIT 4-B', 4, 'BC2440207'),
  ('24-4-0208', 'Jasmine Aquino', 'BSIT 4-B', 4, 'BC2440208'),
  ('24-4-0209', 'Kristine Camacho', 'BSIT 4-B', 4, 'BC2440209'),
  ('24-4-0210', 'Bryan Tolentino', 'BSIT 4-B', 4, 'BC2440210');

-- ─── QUIZZES, QUESTIONS & CHOICES ───────────────────────────
INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Programming Fundamentals I', 'Basic programming concepts and logic', 'Programming', 30, 75.00);
SET @quiz1_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz1_id, 'What is a variable in programming?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A named storage location that holds a value', 1, 0),
  (@q_id, 'A type of loop', 0, 1),
  (@q_id, 'A function call', 0, 2),
  (@q_id, 'A database record', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz1_id, 'Which symbol is used for single-line comments in Python?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '//', 0, 0),
  (@q_id, '/*', 0, 1),
  (@q_id, '#', 1, 2),
  (@q_id, '--', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz1_id, 'What does \'debugging\' mean?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Writing new code', 0, 0),
  (@q_id, 'Finding and fixing errors in a program', 1, 1),
  (@q_id, 'Compiling source code', 0, 2),
  (@q_id, 'Deploying an application', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz1_id, 'Which of the following is NOT a programming language?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Python', 0, 0),
  (@q_id, 'HTML', 1, 1),
  (@q_id, 'Java', 0, 2),
  (@q_id, 'C++', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz1_id, 'What is an algorithm?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of variable', 0, 0),
  (@q_id, 'Step-by-step instructions to solve a problem', 1, 1),
  (@q_id, 'A programming language', 0, 2),
  (@q_id, 'A hardware component', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz1_id, 'What does IDE stand for?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Integrated Development Environment', 1, 0),
  (@q_id, 'Internet Data Exchange', 0, 1),
  (@q_id, 'Internal Design Engine', 0, 2),
  (@q_id, 'Integrated Data Editor', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz1_id, 'Which loop executes at least once before checking the condition?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'for loop', 0, 0),
  (@q_id, 'while loop', 0, 1),
  (@q_id, 'do-while loop', 1, 2),
  (@q_id, 'foreach loop', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz1_id, 'What is the result of 10 % 3 in most programming languages?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '3', 0, 0),
  (@q_id, '1', 1, 1),
  (@q_id, '0', 0, 2),
  (@q_id, '30', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz1_id, 'What is a function in programming?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A variable type', 0, 0),
  (@q_id, 'A reusable block of code', 1, 1),
  (@q_id, 'A database table', 0, 2),
  (@q_id, 'A network protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz1_id, 'What is the purpose of an \'if\' statement?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'To repeat code', 0, 0),
  (@q_id, 'To declare a variable', 0, 1),
  (@q_id, 'To make decisions based on conditions', 1, 2),
  (@q_id, 'To import libraries', 0, 3);

-- End Quiz 1: Programming Fundamentals I

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Python Programming Basics', 'Fundamentals of Python programming', 'Python', 30, 75.00);
SET @quiz2_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz2_id, 'Which keyword defines a function in Python?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'function', 0, 0),
  (@q_id, 'define', 0, 1),
  (@q_id, 'def', 1, 2),
  (@q_id, 'fun', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz2_id, 'What data type does type(\'hello\') return?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'int', 0, 0),
  (@q_id, 'float', 0, 1),
  (@q_id, 'str', 1, 2),
  (@q_id, 'bool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz2_id, 'How do you create an empty list in Python?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'list()', 0, 0),
  (@q_id, '[]', 0, 1),
  (@q_id, 'Both A and B', 1, 2),
  (@q_id, '{}', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz2_id, 'What method adds an element to the end of a list?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'add()', 0, 0),
  (@q_id, 'append()', 1, 1),
  (@q_id, 'insert()', 0, 2),
  (@q_id, 'push()', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz2_id, 'What does \'len([1,2,3])\' return?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '1', 0, 0),
  (@q_id, '2', 0, 1),
  (@q_id, '3', 1, 2),
  (@q_id, '4', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz2_id, 'Which of these is a Python tuple?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '[1,2,3]', 0, 0),
  (@q_id, '{1,2,3}', 0, 1),
  (@q_id, '(1,2,3)', 1, 2),
  (@q_id, '<1,2,3>', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz2_id, 'How do you start a for loop in Python over a list called \'items\'?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'for i in items:', 1, 0),
  (@q_id, 'for(i=0;i<items;i++)', 0, 1),
  (@q_id, 'foreach item in items:', 0, 2),
  (@q_id, 'loop items:', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz2_id, 'What is the output of print(2**3)?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '6', 0, 0),
  (@q_id, '8', 1, 1),
  (@q_id, '9', 0, 2),
  (@q_id, '5', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz2_id, 'Which module is used for regular expressions in Python?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 're', 1, 0),
  (@q_id, 'regex', 0, 1),
  (@q_id, 'regexp', 0, 2),
  (@q_id, 'rx', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz2_id, 'How do you open a file for reading in Python?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'open(\'file.txt\',\'r\')', 1, 0),
  (@q_id, 'read(\'file.txt\')', 0, 1),
  (@q_id, 'file.open(\'file.txt\')', 0, 2),
  (@q_id, 'load(\'file.txt\')', 0, 3);

-- End Quiz 2: Python Programming Basics

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Java Programming Essentials', 'Core Java programming concepts', 'Java', 30, 75.00);
SET @quiz3_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz3_id, 'Which keyword is used to create a class in Java?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'class', 1, 0),
  (@q_id, 'Class', 0, 1),
  (@q_id, 'object', 0, 2),
  (@q_id, 'struct', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz3_id, 'What is the entry point of a Java application?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'start()', 0, 0),
  (@q_id, 'run()', 0, 1),
  (@q_id, 'main()', 1, 2),
  (@q_id, 'init()', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz3_id, 'Which of these is NOT a primitive type in Java?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'int', 0, 0),
  (@q_id, 'String', 1, 1),
  (@q_id, 'boolean', 0, 2),
  (@q_id, 'char', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz3_id, 'What does JVM stand for?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Java Variable Machine', 0, 0),
  (@q_id, 'Java Virtual Machine', 1, 1),
  (@q_id, 'Java Version Manager', 0, 2),
  (@q_id, 'Java Visual Monitor', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz3_id, 'How do you declare a constant in Java?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'const int X=5;', 0, 0),
  (@q_id, 'final int X=5;', 1, 1),
  (@q_id, 'static int X=5;', 0, 2),
  (@q_id, 'fixed int X=5;', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz3_id, 'What is inheritance in Java?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A class acquiring properties of another class', 1, 0),
  (@q_id, 'A loop structure', 0, 1),
  (@q_id, 'A type of variable', 0, 2),
  (@q_id, 'A method of sorting', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz3_id, 'Which access modifier makes a member accessible only within its class?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'public', 0, 0),
  (@q_id, 'protected', 0, 1),
  (@q_id, 'private', 1, 2),
  (@q_id, 'default', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz3_id, 'What keyword creates a new object in Java?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'create', 0, 0),
  (@q_id, 'new', 1, 1),
  (@q_id, 'make', 0, 2),
  (@q_id, 'object', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz3_id, 'What is a Java interface?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of class', 0, 0),
  (@q_id, 'A contract specifying what a class must do', 1, 1),
  (@q_id, 'A loop type', 0, 2),
  (@q_id, 'A package', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz3_id, 'Which exception is thrown when dividing by zero in Java?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'NullPointerException', 0, 0),
  (@q_id, 'ArithmeticException', 1, 1),
  (@q_id, 'IndexOutOfBoundsException', 0, 2),
  (@q_id, 'ClassCastException', 0, 3);

-- End Quiz 3: Java Programming Essentials

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'JavaScript Fundamentals', 'Basics of JavaScript for web development', 'JavaScript', 30, 75.00);
SET @quiz4_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz4_id, 'Which keyword declares a block-scoped variable in JavaScript?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'var', 0, 0),
  (@q_id, 'let', 1, 1),
  (@q_id, 'const', 0, 2),
  (@q_id, 'Both B and C', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz4_id, 'What does \'typeof null\' return in JavaScript?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '\'null\'', 0, 0),
  (@q_id, '\'undefined\'', 0, 1),
  (@q_id, '\'object\'', 1, 2),
  (@q_id, '\'boolean\'', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz4_id, 'How do you select an element by ID in JavaScript?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'document.querySelector(\'.id\')', 0, 0),
  (@q_id, 'document.getElementById(\'id\')', 1, 1),
  (@q_id, 'document.selectId(\'id\')', 0, 2),
  (@q_id, 'document.find(\'id\')', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz4_id, 'Which method converts a JSON string to an object?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'JSON.parse()', 1, 0),
  (@q_id, 'JSON.stringify()', 0, 1),
  (@q_id, 'JSON.convert()', 0, 2),
  (@q_id, 'JSON.decode()', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz4_id, 'What does \'===\' check in JavaScript?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Only value equality', 0, 0),
  (@q_id, 'Value and type equality', 1, 1),
  (@q_id, 'Reference equality', 0, 2),
  (@q_id, 'None of the above', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz4_id, 'What is a callback function?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A function returned by another', 0, 0),
  (@q_id, 'A function passed as an argument to another function', 1, 1),
  (@q_id, 'A recursive function', 0, 2),
  (@q_id, 'A built-in function', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz4_id, 'Which event fires when the DOM is fully loaded?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'onload', 0, 0),
  (@q_id, 'DOMContentLoaded', 1, 1),
  (@q_id, 'onready', 0, 2),
  (@q_id, 'pageload', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz4_id, 'What does \'Array.map()\' do?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Filters elements', 0, 0),
  (@q_id, 'Finds one element', 0, 1),
  (@q_id, 'Creates a new array by transforming each element', 1, 2),
  (@q_id, 'Reduces an array', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz4_id, 'How do you write an arrow function in JavaScript?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'function() =>', 0, 0),
  (@q_id, '() => {}', 1, 1),
  (@q_id, '=> function()', 0, 2),
  (@q_id, 'fun() =>', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz4_id, 'What is \'NaN\' in JavaScript?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A null value', 0, 0),
  (@q_id, 'An undefined variable', 0, 1),
  (@q_id, 'Not a Number', 1, 2),
  (@q_id, 'A network error', 0, 3);

-- End Quiz 4: JavaScript Fundamentals

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'C++ Programming Concepts', 'Fundamental C++ programming topics', 'C++', 30, 75.00);
SET @quiz5_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz5_id, 'What is the correct file extension for a C++ source file?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '.c', 0, 0),
  (@q_id, '.cp', 0, 1),
  (@q_id, '.cpp', 1, 2),
  (@q_id, '.cx', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz5_id, 'Which operator is used for dynamic memory allocation in C++?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'malloc', 0, 0),
  (@q_id, 'new', 1, 1),
  (@q_id, 'alloc', 0, 2),
  (@q_id, 'create', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz5_id, 'What does \'cout\' do in C++?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Reads input', 0, 0),
  (@q_id, 'Outputs data to console', 1, 1),
  (@q_id, 'Declares a variable', 0, 2),
  (@q_id, 'Includes a library', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz5_id, 'What is a pointer in C++?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of loop', 0, 0),
  (@q_id, 'A variable that stores a memory address', 1, 1),
  (@q_id, 'A data structure', 0, 2),
  (@q_id, 'A function type', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz5_id, 'Which concept allows a function to have the same name but different parameters?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Overriding', 0, 0),
  (@q_id, 'Overloading', 1, 1),
  (@q_id, 'Polymorphism', 0, 2),
  (@q_id, 'Encapsulation', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz5_id, 'What does \'#include <iostream>\' do?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Defines a class', 0, 0),
  (@q_id, 'Includes the input/output stream library', 1, 1),
  (@q_id, 'Declares the main function', 0, 2),
  (@q_id, 'Creates a namespace', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz5_id, 'Which keyword is used for inheritance in C++?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'extends', 0, 0),
  (@q_id, 'inherits', 0, 1),
  (@q_id, ':', 1, 2),
  (@q_id, '->', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz5_id, 'What is a destructor in C++?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A constructor with parameters', 0, 0),
  (@q_id, 'A function that frees memory when object is destroyed', 1, 1),
  (@q_id, 'A type of pointer', 0, 2),
  (@q_id, 'An abstract method', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz5_id, 'How do you declare a reference variable to int x in C++?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'int *ref = x;', 0, 0),
  (@q_id, 'int &ref = x;', 1, 1),
  (@q_id, 'int ref -> x;', 0, 2),
  (@q_id, 'ref int = x;', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz5_id, 'What is the Standard Template Library (STL)?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A graphics library', 0, 0),
  (@q_id, 'A collection of C++ template classes and algorithms', 1, 1),
  (@q_id, 'A compiler', 0, 2),
  (@q_id, 'A debugging tool', 0, 3);

-- End Quiz 5: C++ Programming Concepts

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Networking Fundamentals', 'Introduction to computer networking', 'Networking', 30, 75.00);
SET @quiz6_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz6_id, 'What does LAN stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Large Area Network', 0, 0),
  (@q_id, 'Local Area Network', 1, 1),
  (@q_id, 'Linked Area Network', 0, 2),
  (@q_id, 'Light Area Network', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz6_id, 'Which device connects multiple networks together?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Switch', 0, 0),
  (@q_id, 'Hub', 0, 1),
  (@q_id, 'Router', 1, 2),
  (@q_id, 'Repeater', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz6_id, 'What is the primary function of a DNS server?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Assign IP addresses', 0, 0),
  (@q_id, 'Translate domain names to IP addresses', 1, 1),
  (@q_id, 'Filter web traffic', 0, 2),
  (@q_id, 'Encrypt data', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz6_id, 'How many layers does the OSI model have?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '4', 0, 0),
  (@q_id, '5', 0, 1),
  (@q_id, '6', 0, 2),
  (@q_id, '7', 1, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz6_id, 'Which protocol is used to send email?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'HTTP', 0, 0),
  (@q_id, 'FTP', 0, 1),
  (@q_id, 'SMTP', 1, 2),
  (@q_id, 'POP3', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz6_id, 'What does IP stand for?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Internet Protocol', 1, 0),
  (@q_id, 'Internal Program', 0, 1),
  (@q_id, 'Integrated Process', 0, 2),
  (@q_id, 'Internet Path', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz6_id, 'What is a subnet mask used for?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Encrypting data', 0, 0),
  (@q_id, 'Dividing a network into sub-networks', 1, 1),
  (@q_id, 'Assigning MAC addresses', 0, 2),
  (@q_id, 'Routing packets', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz6_id, 'Which port does HTTPS use by default?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '80', 0, 0),
  (@q_id, '8080', 0, 1),
  (@q_id, '443', 1, 2),
  (@q_id, '21', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz6_id, 'What is a MAC address?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A network protocol', 0, 0),
  (@q_id, 'A hardware identifier assigned to a NIC', 1, 1),
  (@q_id, 'A type of IP address', 0, 2),
  (@q_id, 'A routing algorithm', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz6_id, 'What does WAN stand for?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Wireless Area Network', 0, 0),
  (@q_id, 'Wide Area Network', 1, 1),
  (@q_id, 'Web Area Network', 0, 2),
  (@q_id, 'Wired Area Network', 0, 3);

-- End Quiz 6: Networking Fundamentals

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Networking Protocols', 'Common networking protocols and their functions', 'Networking', 30, 75.00);
SET @quiz7_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz7_id, 'Which protocol assigns IP addresses automatically?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'DNS', 0, 0),
  (@q_id, 'DHCP', 1, 1),
  (@q_id, 'FTP', 0, 2),
  (@q_id, 'SMTP', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz7_id, 'What protocol is used for secure web browsing?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'HTTP', 0, 0),
  (@q_id, 'FTP', 0, 1),
  (@q_id, 'HTTPS', 1, 2),
  (@q_id, 'SFTP', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz7_id, 'Which protocol transfers files between computers?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'HTTP', 0, 0),
  (@q_id, 'SMTP', 0, 1),
  (@q_id, 'FTP', 1, 2),
  (@q_id, 'ICMP', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz7_id, 'What does TCP stand for?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Transfer Control Protocol', 0, 0),
  (@q_id, 'Transmission Control Protocol', 1, 1),
  (@q_id, 'Transport Connection Protocol', 0, 2),
  (@q_id, 'Tunneling Control Protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz7_id, 'Which protocol is connectionless?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'TCP', 0, 0),
  (@q_id, 'FTP', 0, 1),
  (@q_id, 'UDP', 1, 2),
  (@q_id, 'SMTP', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz7_id, 'What is the purpose of ICMP?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'File transfer', 0, 0),
  (@q_id, 'Error reporting and diagnostics', 1, 1),
  (@q_id, 'Email delivery', 0, 2),
  (@q_id, 'IP address assignment', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz7_id, 'Which protocol is used to retrieve email from a server?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'SMTP', 0, 0),
  (@q_id, 'IMAP', 1, 1),
  (@q_id, 'FTP', 0, 2),
  (@q_id, 'HTTP', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz7_id, 'What port does SSH use?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '21', 0, 0),
  (@q_id, '22', 1, 1),
  (@q_id, '23', 0, 2),
  (@q_id, '25', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz7_id, 'Which protocol is used by routers to exchange routing information?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'ARP', 0, 0),
  (@q_id, 'OSPF', 1, 1),
  (@q_id, 'DHCP', 0, 2),
  (@q_id, 'DNS', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz7_id, 'What does ARP stand for?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Address Resolution Protocol', 1, 0),
  (@q_id, 'Automatic Routing Protocol', 0, 1),
  (@q_id, 'Access Request Protocol', 0, 2),
  (@q_id, 'Application Routing Protocol', 0, 3);

-- End Quiz 7: Networking Protocols

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'TCP/IP Model', 'Understanding the TCP/IP networking model', 'Networking', 30, 75.00);
SET @quiz8_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz8_id, 'How many layers does the TCP/IP model have?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '3', 0, 0),
  (@q_id, '4', 1, 1),
  (@q_id, '5', 0, 2),
  (@q_id, '7', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz8_id, 'Which layer of TCP/IP handles end-to-end communication?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Network', 0, 0),
  (@q_id, 'Transport', 1, 1),
  (@q_id, 'Application', 0, 2),
  (@q_id, 'Link', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz8_id, 'What layer does IP operate at in the TCP/IP model?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Application', 0, 0),
  (@q_id, 'Transport', 0, 1),
  (@q_id, 'Internet', 1, 2),
  (@q_id, 'Link', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz8_id, 'What is the purpose of the Transport layer?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Physical transmission', 0, 0),
  (@q_id, 'Routing', 0, 1),
  (@q_id, 'Reliable data transfer between processes', 1, 2),
  (@q_id, 'Application services', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz8_id, 'Which protocol at the Internet layer routes packets?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'TCP', 0, 0),
  (@q_id, 'IP', 1, 1),
  (@q_id, 'UDP', 0, 2),
  (@q_id, 'HTTP', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz8_id, 'What does TTL stand for in IP headers?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Time To Live', 1, 0),
  (@q_id, 'Transfer To Location', 0, 1),
  (@q_id, 'Tunnel Tag Level', 0, 2),
  (@q_id, 'Time To Load', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz8_id, 'Which address is used at the Internet layer?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'MAC address', 0, 0),
  (@q_id, 'IP address', 1, 1),
  (@q_id, 'Port number', 0, 2),
  (@q_id, 'Domain name', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz8_id, 'What is the difference between TCP and UDP?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'TCP is faster', 0, 0),
  (@q_id, 'UDP provides reliability', 0, 1),
  (@q_id, 'TCP provides reliability; UDP does not', 1, 2),
  (@q_id, 'There is no difference', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz8_id, 'What is a socket in networking?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A physical port', 0, 0),
  (@q_id, 'A combination of IP address and port number', 1, 1),
  (@q_id, 'A type of cable', 0, 2),
  (@q_id, 'A routing algorithm', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz8_id, 'Which protocol resolves IP addresses to MAC addresses?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'DNS', 0, 0),
  (@q_id, 'DHCP', 0, 1),
  (@q_id, 'ARP', 1, 2),
  (@q_id, 'ICMP', 0, 3);

-- End Quiz 8: TCP/IP Model

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'OSI Model Deep Dive', 'Detailed study of the OSI reference model', 'Networking', 30, 75.00);
SET @quiz9_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz9_id, 'At which OSI layer does a router operate?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Layer 1', 0, 0),
  (@q_id, 'Layer 2', 0, 1),
  (@q_id, 'Layer 3', 1, 2),
  (@q_id, 'Layer 4', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz9_id, 'Which OSI layer is responsible for data encryption?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Layer 3', 0, 0),
  (@q_id, 'Layer 4', 0, 1),
  (@q_id, 'Layer 5', 0, 2),
  (@q_id, 'Layer 6', 1, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz9_id, 'What OSI layer converts data to bits for transmission?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Layer 1', 1, 0),
  (@q_id, 'Layer 2', 0, 1),
  (@q_id, 'Layer 3', 0, 2),
  (@q_id, 'Layer 7', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz9_id, 'At which OSI layer does a switch operate?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Layer 1', 0, 0),
  (@q_id, 'Layer 2', 1, 1),
  (@q_id, 'Layer 3', 0, 2),
  (@q_id, 'Layer 4', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz9_id, 'Which OSI layer manages sessions between applications?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Layer 4', 0, 0),
  (@q_id, 'Layer 5', 1, 1),
  (@q_id, 'Layer 6', 0, 2),
  (@q_id, 'Layer 7', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz9_id, 'What is the function of the Transport layer (Layer 4)?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Physical addressing', 0, 0),
  (@q_id, 'Routing', 0, 1),
  (@q_id, 'Segmentation and reassembly of data', 1, 2),
  (@q_id, 'Application services', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz9_id, 'Which PDU (Protocol Data Unit) is used at Layer 2?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Bit', 0, 0),
  (@q_id, 'Frame', 1, 1),
  (@q_id, 'Packet', 0, 2),
  (@q_id, 'Segment', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz9_id, 'What does the Application layer (Layer 7) provide?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Physical connectivity', 0, 0),
  (@q_id, 'Network addressing', 0, 1),
  (@q_id, 'User interface and application services', 1, 2),
  (@q_id, 'Error detection', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz9_id, 'Which OSI layer is responsible for MAC addressing?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Layer 1', 0, 0),
  (@q_id, 'Layer 2', 1, 1),
  (@q_id, 'Layer 3', 0, 2),
  (@q_id, 'Layer 4', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz9_id, 'What is the PDU at the Transport layer called?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Bit', 0, 0),
  (@q_id, 'Frame', 0, 1),
  (@q_id, 'Packet', 0, 2),
  (@q_id, 'Segment', 1, 3);

-- End Quiz 9: OSI Model Deep Dive

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Wireless Networking', 'Concepts and standards in wireless networking', 'Networking', 30, 75.00);
SET @quiz10_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz10_id, 'What does WiFi stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Wireless Fidelity', 1, 0),
  (@q_id, 'Wide Frequency', 0, 1),
  (@q_id, 'Wireless Fiber', 0, 2),
  (@q_id, 'Web Interface', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz10_id, 'Which IEEE standard defines WiFi?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '802.3', 0, 0),
  (@q_id, '802.11', 1, 1),
  (@q_id, '802.15', 0, 2),
  (@q_id, '802.16', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz10_id, 'What frequency does Bluetooth typically use?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '2.4 GHz', 1, 0),
  (@q_id, '5 GHz', 0, 1),
  (@q_id, '900 MHz', 0, 2),
  (@q_id, '60 GHz', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz10_id, 'What is SSID?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A security protocol', 0, 0),
  (@q_id, 'The name of a wireless network', 1, 1),
  (@q_id, 'An IP address type', 0, 2),
  (@q_id, 'A routing protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz10_id, 'Which WiFi security protocol is considered most secure?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'WEP', 0, 0),
  (@q_id, 'WPA', 0, 1),
  (@q_id, 'WPA2', 0, 2),
  (@q_id, 'WPA3', 1, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz10_id, 'What does a wireless access point do?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Routes packets between networks', 0, 0),
  (@q_id, 'Allows wireless devices to connect to a wired network', 1, 1),
  (@q_id, 'Assigns IP addresses', 0, 2),
  (@q_id, 'Encrypts all traffic', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz10_id, 'What does MIMO stand for in WiFi technology?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Multiple Input Multiple Output', 1, 0),
  (@q_id, 'Managed Input Managed Output', 0, 1),
  (@q_id, 'Multi Interface Multi Operation', 0, 2),
  (@q_id, 'Maximum Input Minimum Output', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz10_id, 'Which band offers higher throughput but shorter range?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '2.4 GHz', 0, 0),
  (@q_id, '5 GHz', 1, 1),
  (@q_id, '900 MHz', 0, 2),
  (@q_id, '60 GHz', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz10_id, 'What is a hotspot?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of router', 0, 0),
  (@q_id, 'A public wireless access point', 1, 1),
  (@q_id, 'A wireless security flaw', 0, 2),
  (@q_id, 'A network switch', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz10_id, 'What is the range of Bluetooth Classic?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '1 meter', 0, 0),
  (@q_id, '10 meters', 1, 1),
  (@q_id, '100 meters', 0, 2),
  (@q_id, '1 kilometer', 0, 3);

-- End Quiz 10: Wireless Networking

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Database Management Fundamentals', 'Introduction to database concepts', 'Database', 30, 75.00);
SET @quiz11_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz11_id, 'What does DBMS stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Database Management System', 1, 0),
  (@q_id, 'Data Backup Management Software', 0, 1),
  (@q_id, 'Digital Base Management System', 0, 2),
  (@q_id, 'Database Modelling Software', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz11_id, 'Which type of database stores data in tables?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'NoSQL', 0, 0),
  (@q_id, 'Relational', 1, 1),
  (@q_id, 'Hierarchical', 0, 2),
  (@q_id, 'Graph', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz11_id, 'What is a primary key?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A key used for encryption', 0, 0),
  (@q_id, 'A column that uniquely identifies each row', 1, 1),
  (@q_id, 'A foreign key', 0, 2),
  (@q_id, 'A composite index', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz11_id, 'What does SQL stand for?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Structured Query Language', 1, 0),
  (@q_id, 'Standard Query Logic', 0, 1),
  (@q_id, 'Sequential Query Language', 0, 2),
  (@q_id, 'Simple Query Layer', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz11_id, 'What is a foreign key?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A key from another table used to link records', 1, 0),
  (@q_id, 'A primary key in disguise', 0, 1),
  (@q_id, 'An encrypted key', 0, 2),
  (@q_id, 'A composite key', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz11_id, 'Which SQL statement retrieves data from a table?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'INSERT', 0, 0),
  (@q_id, 'UPDATE', 0, 1),
  (@q_id, 'SELECT', 1, 2),
  (@q_id, 'DELETE', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz11_id, 'What is normalization in databases?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Adding more data', 0, 0),
  (@q_id, 'Organizing data to reduce redundancy', 1, 1),
  (@q_id, 'Encrypting the database', 0, 2),
  (@q_id, 'Creating indexes', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz11_id, 'What is a transaction in database management?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A single SQL query', 0, 0),
  (@q_id, 'A unit of work that must be completed entirely or not at all', 1, 1),
  (@q_id, 'A type of join', 0, 2),
  (@q_id, 'A backup operation', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz11_id, 'Which constraint ensures no NULL values in a column?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'UNIQUE', 0, 0),
  (@q_id, 'PRIMARY KEY', 0, 1),
  (@q_id, 'NOT NULL', 1, 2),
  (@q_id, 'CHECK', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz11_id, 'What does CRUD stand for?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Create, Read, Update, Delete', 1, 0),
  (@q_id, 'Copy, Remove, Upload, Download', 0, 1),
  (@q_id, 'Connect, Read, Update, Deploy', 0, 2),
  (@q_id, 'Create, Remove, Update, Duplicate', 0, 3);

-- End Quiz 11: Database Management Fundamentals

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'SQL Queries and Commands', 'Writing and understanding SQL queries', 'SQL', 30, 75.00);
SET @quiz12_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz12_id, 'Which SQL clause filters rows?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'ORDER BY', 0, 0),
  (@q_id, 'GROUP BY', 0, 1),
  (@q_id, 'WHERE', 1, 2),
  (@q_id, 'HAVING', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz12_id, 'What does \'SELECT DISTINCT\' do?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Selects all rows', 0, 0),
  (@q_id, 'Returns unique values only', 1, 1),
  (@q_id, 'Selects the first row', 0, 2),
  (@q_id, 'Deletes duplicates', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz12_id, 'Which aggregate function counts rows?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'SUM()', 0, 0),
  (@q_id, 'AVG()', 0, 1),
  (@q_id, 'COUNT()', 1, 2),
  (@q_id, 'MAX()', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz12_id, 'What is the purpose of \'GROUP BY\'?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Filter rows', 0, 0),
  (@q_id, 'Sort results', 0, 1),
  (@q_id, 'Group rows sharing a value for aggregation', 1, 2),
  (@q_id, 'Join tables', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz12_id, 'Which JOIN returns all rows from both tables?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'INNER JOIN', 0, 0),
  (@q_id, 'LEFT JOIN', 0, 1),
  (@q_id, 'RIGHT JOIN', 0, 2),
  (@q_id, 'FULL OUTER JOIN', 1, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz12_id, 'What does the \'HAVING\' clause do?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Filters rows before grouping', 0, 0),
  (@q_id, 'Filters groups after GROUP BY', 1, 1),
  (@q_id, 'Sorts results', 0, 2),
  (@q_id, 'Joins tables', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz12_id, 'Which command adds a new row to a table?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'UPDATE', 0, 0),
  (@q_id, 'INSERT INTO', 1, 1),
  (@q_id, 'ALTER', 0, 2),
  (@q_id, 'MERGE', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz12_id, 'What does \'ORDER BY DESC\' do?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Sorts ascending', 0, 0),
  (@q_id, 'Sorts descending', 1, 1),
  (@q_id, 'Filters results', 0, 2),
  (@q_id, 'Groups results', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz12_id, 'Which SQL command modifies existing data?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'INSERT', 0, 0),
  (@q_id, 'SELECT', 0, 1),
  (@q_id, 'UPDATE', 1, 2),
  (@q_id, 'DROP', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz12_id, 'What does \'DROP TABLE\' do?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Removes all rows', 0, 0),
  (@q_id, 'Deletes the entire table and its structure', 1, 1),
  (@q_id, 'Resets auto-increment', 0, 2),
  (@q_id, 'Removes an index', 0, 3);

-- End Quiz 12: SQL Queries and Commands

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Database Normalization', 'Normal forms and database design principles', 'Database', 30, 75.00);
SET @quiz13_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz13_id, 'What is the goal of database normalization?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Increase redundancy', 0, 0),
  (@q_id, 'Reduce data redundancy and improve integrity', 1, 1),
  (@q_id, 'Speed up queries', 0, 2),
  (@q_id, 'Add more tables', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz13_id, 'Which normal form eliminates partial dependencies?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '1NF', 0, 0),
  (@q_id, '2NF', 1, 1),
  (@q_id, '3NF', 0, 2),
  (@q_id, 'BCNF', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz13_id, 'A table is in 1NF if:', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'It has no repeating groups and all values are atomic', 1, 0),
  (@q_id, 'It has no transitive dependencies', 0, 1),
  (@q_id, 'It has a single candidate key', 0, 2),
  (@q_id, 'All columns depend on primary key', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz13_id, 'What is a transitive dependency?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'When a non-key attribute depends on another non-key attribute', 1, 0),
  (@q_id, 'When two keys conflict', 0, 1),
  (@q_id, 'When a foreign key references itself', 0, 2),
  (@q_id, 'When data is duplicated', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz13_id, 'Which normal form removes transitive dependencies?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '1NF', 0, 0),
  (@q_id, '2NF', 0, 1),
  (@q_id, '3NF', 1, 2),
  (@q_id, '4NF', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz13_id, 'What is denormalization?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Increasing normal forms', 0, 0),
  (@q_id, 'Intentionally introducing redundancy for performance', 1, 1),
  (@q_id, 'Removing all indexes', 0, 2),
  (@q_id, 'Encrypting data', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz13_id, 'What is a composite key?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A key with encrypted values', 0, 0),
  (@q_id, 'A primary key made of multiple columns', 1, 1),
  (@q_id, 'A foreign key', 0, 2),
  (@q_id, 'A unique index', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz13_id, 'What is BCNF?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A form weaker than 3NF', 0, 0),
  (@q_id, 'A stricter version of 3NF', 1, 1),
  (@q_id, 'Same as 2NF', 0, 2),
  (@q_id, 'A type of join', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz13_id, 'In 2NF, all non-key attributes must depend on:', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Part of the primary key', 0, 0),
  (@q_id, 'The entire primary key', 1, 1),
  (@q_id, 'Any column', 0, 2),
  (@q_id, 'A foreign key', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz13_id, 'What is an anomaly in database design?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of query', 0, 0),
  (@q_id, 'An inconsistency caused by poor design', 1, 1),
  (@q_id, 'A normal form', 0, 2),
  (@q_id, 'An index type', 0, 3);

-- End Quiz 13: Database Normalization

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Database Transactions and ACID', 'Transaction management and ACID properties', 'Database', 30, 75.00);
SET @quiz14_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz14_id, 'What does ACID stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Atomicity, Consistency, Isolation, Durability', 1, 0),
  (@q_id, 'Accuracy, Concurrency, Integrity, Data', 0, 1),
  (@q_id, 'Atomicity, Consistency, Integrity, Durability', 0, 2),
  (@q_id, 'Access, Control, Isolation, Data', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz14_id, 'What does Atomicity in ACID mean?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Transactions are fast', 0, 0),
  (@q_id, 'All operations succeed or all fail', 1, 1),
  (@q_id, 'Data is never lost', 0, 2),
  (@q_id, 'Transactions run simultaneously', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz14_id, 'What is a deadlock in databases?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A slow query', 0, 0),
  (@q_id, 'Two transactions waiting for each other indefinitely', 1, 1),
  (@q_id, 'A corrupted index', 0, 2),
  (@q_id, 'A missing foreign key', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz14_id, 'What does COMMIT do?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Rolls back a transaction', 0, 0),
  (@q_id, 'Permanently saves a transaction', 1, 1),
  (@q_id, 'Locks a table', 0, 2),
  (@q_id, 'Deletes records', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz14_id, 'What does ROLLBACK do?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Saves the transaction', 0, 0),
  (@q_id, 'Undoes the transaction', 1, 1),
  (@q_id, 'Locks the table', 0, 2),
  (@q_id, 'Creates a savepoint', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz14_id, 'What is a savepoint?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A backup of a table', 0, 0),
  (@q_id, 'A point within a transaction you can roll back to', 1, 1),
  (@q_id, 'A type of index', 0, 2),
  (@q_id, 'A constraint', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz14_id, 'What is Isolation in ACID?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Transactions don\'t interfere with each other', 1, 0),
  (@q_id, 'Data is always backed up', 0, 1),
  (@q_id, 'Transactions are permanent', 0, 2),
  (@q_id, 'Transactions are atomic', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz14_id, 'What is a dirty read?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Reading uncommitted data from another transaction', 1, 0),
  (@q_id, 'Reading encrypted data', 0, 1),
  (@q_id, 'Reading a NULL value', 0, 2),
  (@q_id, 'Reading from an index', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz14_id, 'What is Durability in ACID?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Data is encrypted', 0, 0),
  (@q_id, 'Committed data persists even after system failure', 1, 1),
  (@q_id, 'Transactions are isolated', 0, 2),
  (@q_id, 'Data is consistent', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz14_id, 'Which isolation level prevents dirty reads?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Read Uncommitted', 0, 0),
  (@q_id, 'Read Committed', 1, 1),
  (@q_id, 'Repeatable Read', 0, 2),
  (@q_id, 'Serializable', 0, 3);

-- End Quiz 14: Database Transactions and ACID

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'NoSQL Databases', 'Introduction to NoSQL database systems', 'Database', 30, 75.00);
SET @quiz15_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz15_id, 'What does NoSQL stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'No Standard Query Language', 0, 0),
  (@q_id, 'Not Only SQL', 1, 1),
  (@q_id, 'Non-Object SQL', 0, 2),
  (@q_id, 'No Structured Query Language', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz15_id, 'Which of these is a document-oriented NoSQL database?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'MySQL', 0, 0),
  (@q_id, 'PostgreSQL', 0, 1),
  (@q_id, 'MongoDB', 1, 2),
  (@q_id, 'Redis', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz15_id, 'What is a key-value store?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A relational table', 0, 0),
  (@q_id, 'A NoSQL database that stores data as key-value pairs', 1, 1),
  (@q_id, 'A graph database', 0, 2),
  (@q_id, 'A column-family database', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz15_id, 'Which NoSQL database is best known for caching?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'MongoDB', 0, 0),
  (@q_id, 'Cassandra', 0, 1),
  (@q_id, 'Redis', 1, 2),
  (@q_id, 'Neo4j', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz15_id, 'What type of database is Neo4j?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Document', 0, 0),
  (@q_id, 'Key-Value', 0, 1),
  (@q_id, 'Graph', 1, 2),
  (@q_id, 'Column-Family', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz15_id, 'What is horizontal scaling?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Adding more power to one server', 0, 0),
  (@q_id, 'Adding more servers to distribute load', 1, 1),
  (@q_id, 'Increasing storage capacity', 0, 2),
  (@q_id, 'Upgrading RAM', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz15_id, 'Which of these is a column-family NoSQL database?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'MongoDB', 0, 0),
  (@q_id, 'Redis', 0, 1),
  (@q_id, 'Cassandra', 1, 2),
  (@q_id, 'CouchDB', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz15_id, 'What format do document databases typically use?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'XML only', 0, 0),
  (@q_id, 'JSON or BSON', 1, 1),
  (@q_id, 'CSV', 0, 2),
  (@q_id, 'Binary', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz15_id, 'What is eventual consistency in NoSQL?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Data is always immediately consistent', 0, 0),
  (@q_id, 'Data will become consistent over time', 1, 1),
  (@q_id, 'Data is never consistent', 0, 2),
  (@q_id, 'Data requires transactions', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz15_id, 'Which property does NoSQL sacrifice for scalability?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Speed', 0, 0),
  (@q_id, 'ACID compliance', 1, 1),
  (@q_id, 'Storage', 0, 2),
  (@q_id, 'Security', 0, 3);

-- End Quiz 15: NoSQL Databases

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'HTML Fundamentals', 'Core HTML concepts for web development', 'Web Development', 30, 75.00);
SET @quiz16_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz16_id, 'What does HTML stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'HyperText Markup Language', 1, 0),
  (@q_id, 'High Transfer Markup Language', 0, 1),
  (@q_id, 'Hyper Transfer Modeling Language', 0, 2),
  (@q_id, 'HyperText Management Language', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz16_id, 'Which tag defines the largest heading in HTML?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '<h6>', 0, 0),
  (@q_id, '<header>', 0, 1),
  (@q_id, '<h1>', 1, 2),
  (@q_id, '<title>', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz16_id, 'What attribute specifies the URL of a hyperlink?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'src', 0, 0),
  (@q_id, 'href', 1, 1),
  (@q_id, 'link', 0, 2),
  (@q_id, 'url', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz16_id, 'Which tag is used to insert an image?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '<image>', 0, 0),
  (@q_id, '<img>', 1, 1),
  (@q_id, '<picture>', 0, 2),
  (@q_id, '<photo>', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz16_id, 'What is the correct HTML element for a line break?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '<br>', 1, 0),
  (@q_id, '<lb>', 0, 1),
  (@q_id, '<break>', 0, 2),
  (@q_id, '<newline>', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz16_id, 'Which HTML tag creates an unordered list?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '<ol>', 0, 0),
  (@q_id, '<ul>', 1, 1),
  (@q_id, '<li>', 0, 2),
  (@q_id, '<list>', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz16_id, 'What does the \'alt\' attribute in an img tag do?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Changes image size', 0, 0),
  (@q_id, 'Provides alternative text if image fails to load', 1, 1),
  (@q_id, 'Sets image alignment', 0, 2),
  (@q_id, 'Changes image color', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz16_id, 'What tag wraps the visible content of a webpage?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '<head>', 0, 0),
  (@q_id, '<html>', 0, 1),
  (@q_id, '<body>', 1, 2),
  (@q_id, '<main>', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz16_id, 'Which element defines a table row?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '<td>', 0, 0),
  (@q_id, '<th>', 0, 1),
  (@q_id, '<tr>', 1, 2),
  (@q_id, '<table>', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz16_id, 'What is the purpose of the <form> tag?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Display images', 0, 0),
  (@q_id, 'Create hyperlinks', 0, 1),
  (@q_id, 'Collect user input', 1, 2),
  (@q_id, 'Define scripts', 0, 3);

-- End Quiz 16: HTML Fundamentals

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'CSS Styling and Layout', 'CSS concepts for styling web pages', 'Web Development', 30, 75.00);
SET @quiz17_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz17_id, 'What does CSS stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Computer Style Sheets', 0, 0),
  (@q_id, 'Cascading Style Sheets', 1, 1),
  (@q_id, 'Creative Style System', 0, 2),
  (@q_id, 'Consistent Style Sheets', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz17_id, 'Which CSS property changes text color?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'background-color', 0, 0),
  (@q_id, 'font-color', 0, 1),
  (@q_id, 'color', 1, 2),
  (@q_id, 'text-color', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz17_id, 'What does \'display: flex\' enable?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Grid layout', 0, 0),
  (@q_id, 'Flexbox layout', 1, 1),
  (@q_id, 'Block layout', 0, 2),
  (@q_id, 'Inline layout', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz17_id, 'Which unit is relative to the viewport width?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'px', 0, 0),
  (@q_id, 'em', 0, 1),
  (@q_id, 'rem', 0, 2),
  (@q_id, 'vw', 1, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz17_id, 'What does the CSS \'margin\' property control?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Space inside an element', 0, 0),
  (@q_id, 'Space outside an element', 1, 1),
  (@q_id, 'Element border', 0, 2),
  (@q_id, 'Element padding', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz17_id, 'Which selector targets all <p> elements?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '#p', 0, 0),
  (@q_id, '.p', 0, 1),
  (@q_id, 'p', 1, 2),
  (@q_id, '*p', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz17_id, 'What is the CSS box model?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A 3D layout system', 0, 0),
  (@q_id, 'Content, padding, border, and margin layers around elements', 1, 1),
  (@q_id, 'A grid system', 0, 2),
  (@q_id, 'A flexbox container', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz17_id, 'Which property makes an element invisible but still occupies space?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'display:none', 0, 0),
  (@q_id, 'visibility:hidden', 0, 1),
  (@q_id, 'opacity:0', 0, 2),
  (@q_id, 'Both B and C', 1, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz17_id, 'What does \'position: absolute\' do?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Positions relative to viewport', 0, 0),
  (@q_id, 'Positions relative to nearest positioned ancestor', 1, 1),
  (@q_id, 'Fixes element on scroll', 0, 2),
  (@q_id, 'Positions relative to parent element always', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz17_id, 'Which CSS property adds shadow to text?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'box-shadow', 0, 0),
  (@q_id, 'text-shadow', 1, 1),
  (@q_id, 'font-shadow', 0, 2),
  (@q_id, 'shadow', 0, 3);

-- End Quiz 17: CSS Styling and Layout

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'JavaScript DOM Manipulation', 'Working with the Document Object Model', 'JavaScript', 30, 75.00);
SET @quiz18_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz18_id, 'What does DOM stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Document Object Model', 1, 0),
  (@q_id, 'Data Object Management', 0, 1),
  (@q_id, 'Document Order Map', 0, 2),
  (@q_id, 'Dynamic Object Model', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz18_id, 'Which method selects the first matching element?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'getElementById', 0, 0),
  (@q_id, 'querySelector', 1, 1),
  (@q_id, 'getElementsByClassName', 0, 2),
  (@q_id, 'getElement', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz18_id, 'How do you add a CSS class to an element via JS?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'element.style.class = \'name\'', 0, 0),
  (@q_id, 'element.className += \'name\'', 0, 1),
  (@q_id, 'element.classList.add(\'name\')', 1, 2),
  (@q_id, 'element.addCss(\'name\')', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz18_id, 'Which event fires when a button is clicked?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'onhover', 0, 0),
  (@q_id, 'onchange', 0, 1),
  (@q_id, 'onclick', 1, 2),
  (@q_id, 'onfocus', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz18_id, 'What does \'innerHTML\' do?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Returns element\'s tag name', 0, 0),
  (@q_id, 'Gets or sets the HTML content inside an element', 1, 1),
  (@q_id, 'Changes element style', 0, 2),
  (@q_id, 'Removes child elements', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz18_id, 'How do you create a new element in JavaScript?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'document.newElement(\'div\')', 0, 0),
  (@q_id, 'document.createElement(\'div\')', 1, 1),
  (@q_id, 'document.makeElement(\'div\')', 0, 2),
  (@q_id, 'new Element(\'div\')', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz18_id, 'Which method appends a child element?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'addChild()', 0, 0),
  (@q_id, 'appendChild()', 1, 1),
  (@q_id, 'insertChild()', 0, 2),
  (@q_id, 'pushChild()', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz18_id, 'What does \'event.preventDefault()\' do?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Stops event propagation', 0, 0),
  (@q_id, 'Prevents the default browser action for an event', 1, 1),
  (@q_id, 'Removes the event listener', 0, 2),
  (@q_id, 'Delays the event', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz18_id, 'How do you remove an element from the DOM?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'element.delete()', 0, 0),
  (@q_id, 'element.remove()', 1, 1),
  (@q_id, 'document.remove(element)', 0, 2),
  (@q_id, 'element.destroy()', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz18_id, 'What is event bubbling?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'An event travels from child to parent', 1, 0),
  (@q_id, 'An event travels from parent to child', 0, 1),
  (@q_id, 'An event is cancelled', 0, 2),
  (@q_id, 'An event fires multiple times', 0, 3);

-- End Quiz 18: JavaScript DOM Manipulation

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'React.js Fundamentals', 'Core concepts of React.js framework', 'React', 30, 75.00);
SET @quiz19_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz19_id, 'What is React?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A server-side framework', 0, 0),
  (@q_id, 'A JavaScript library for building user interfaces', 1, 1),
  (@q_id, 'A database ORM', 0, 2),
  (@q_id, 'A CSS framework', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz19_id, 'What is a React component?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A database model', 0, 0),
  (@q_id, 'A reusable piece of UI', 1, 1),
  (@q_id, 'A routing module', 0, 2),
  (@q_id, 'A state manager', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz19_id, 'What does JSX stand for?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'JavaScript XML', 1, 0),
  (@q_id, 'JavaScript Extension', 0, 1),
  (@q_id, 'Java Syntax Extension', 0, 2),
  (@q_id, 'JavaScript Extra', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz19_id, 'Which hook manages local state in a functional component?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'useEffect', 0, 0),
  (@q_id, 'useState', 1, 1),
  (@q_id, 'useContext', 0, 2),
  (@q_id, 'useReducer', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz19_id, 'What does \'useEffect\' do?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Manages state', 0, 0),
  (@q_id, 'Performs side effects after rendering', 1, 1),
  (@q_id, 'Creates context', 0, 2),
  (@q_id, 'Memoizes values', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz19_id, 'What is the virtual DOM?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A 3D rendering engine', 0, 0),
  (@q_id, 'A lightweight copy of the real DOM used for efficient updates', 1, 1),
  (@q_id, 'A server-side DOM', 0, 2),
  (@q_id, 'A CSS layout system', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz19_id, 'What are props in React?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'State variables', 0, 0),
  (@q_id, 'Data passed from parent to child components', 1, 1),
  (@q_id, 'Event handlers', 0, 2),
  (@q_id, 'Lifecycle methods', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz19_id, 'What does \'key\' prop do in a list?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Styles list items', 0, 0),
  (@q_id, 'Helps React identify which items have changed', 1, 1),
  (@q_id, 'Sorts list items', 0, 2),
  (@q_id, 'Filters list items', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz19_id, 'What is React Router used for?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'State management', 0, 0),
  (@q_id, 'Navigation between pages', 1, 1),
  (@q_id, 'API calls', 0, 2),
  (@q_id, 'Styling components', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz19_id, 'Which hook is used for context consumption?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'useState', 0, 0),
  (@q_id, 'useEffect', 0, 1),
  (@q_id, 'useContext', 1, 2),
  (@q_id, 'useCallback', 0, 3);

-- End Quiz 19: React.js Fundamentals

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'REST APIs and Web Services', 'Understanding RESTful APIs and web services', 'Web Development', 30, 75.00);
SET @quiz20_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz20_id, 'What does REST stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Remote Entry System Technology', 0, 0),
  (@q_id, 'Representational State Transfer', 1, 1),
  (@q_id, 'Rapid Encoding Standard Technology', 0, 2),
  (@q_id, 'Remote State Transfer', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz20_id, 'Which HTTP method retrieves data?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'POST', 0, 0),
  (@q_id, 'PUT', 0, 1),
  (@q_id, 'GET', 1, 2),
  (@q_id, 'DELETE', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz20_id, 'Which HTTP method submits new data to a server?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'GET', 0, 0),
  (@q_id, 'POST', 1, 1),
  (@q_id, 'PUT', 0, 2),
  (@q_id, 'PATCH', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz20_id, 'What does HTTP status code 404 mean?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Server error', 0, 0),
  (@q_id, 'Unauthorized', 0, 1),
  (@q_id, 'Not Found', 1, 2),
  (@q_id, 'OK', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz20_id, 'What format is most commonly used for REST API data?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'XML', 0, 0),
  (@q_id, 'JSON', 1, 1),
  (@q_id, 'CSV', 0, 2),
  (@q_id, 'HTML', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz20_id, 'What does HTTP status 200 indicate?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Created', 0, 0),
  (@q_id, 'Redirect', 0, 1),
  (@q_id, 'OK', 1, 2),
  (@q_id, 'Bad Request', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz20_id, 'Which HTTP method updates a resource completely?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'GET', 0, 0),
  (@q_id, 'POST', 0, 1),
  (@q_id, 'PUT', 1, 2),
  (@q_id, 'PATCH', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz20_id, 'What is an API endpoint?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A server', 0, 0),
  (@q_id, 'A URL where a resource can be accessed', 1, 1),
  (@q_id, 'A database table', 0, 2),
  (@q_id, 'A client application', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz20_id, 'What does CORS stand for?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Cross-Origin Resource Sharing', 1, 0),
  (@q_id, 'Client-Origin Request System', 0, 1),
  (@q_id, 'Cross-Object Resource Sharing', 0, 2),
  (@q_id, 'Connected Origin Resource Set', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz20_id, 'What HTTP status code indicates a resource was created?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '200', 0, 0),
  (@q_id, '201', 1, 1),
  (@q_id, '400', 0, 2),
  (@q_id, '500', 0, 3);

-- End Quiz 20: REST APIs and Web Services

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Cybersecurity Fundamentals', 'Introduction to cybersecurity concepts', 'Cybersecurity', 30, 75.00);
SET @quiz21_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz21_id, 'What is cybersecurity?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Designing websites', 0, 0),
  (@q_id, 'Protection of computer systems from theft or damage', 1, 1),
  (@q_id, 'Building mobile apps', 0, 2),
  (@q_id, 'Managing databases', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz21_id, 'What is a firewall?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of virus', 0, 0),
  (@q_id, 'A network security device that monitors traffic', 1, 1),
  (@q_id, 'A backup system', 0, 2),
  (@q_id, 'An encryption algorithm', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz21_id, 'What is social engineering in cybersecurity?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Hacking hardware', 0, 0),
  (@q_id, 'Manipulating people into revealing confidential information', 1, 1),
  (@q_id, 'Bypassing firewalls', 0, 2),
  (@q_id, 'A coding technique', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz21_id, 'What is phishing?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of malware', 0, 0),
  (@q_id, 'Sending fraudulent messages to steal credentials', 1, 1),
  (@q_id, 'A network scan', 0, 2),
  (@q_id, 'A type of firewall', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz21_id, 'What does VPN stand for?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Virtual Private Network', 1, 0),
  (@q_id, 'Very Private Network', 0, 1),
  (@q_id, 'Virtual Protocol Node', 0, 2),
  (@q_id, 'Verified Private Node', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz21_id, 'What is malware?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A programming language', 0, 0),
  (@q_id, 'Software designed to disrupt or damage computer systems', 1, 1),
  (@q_id, 'A network protocol', 0, 2),
  (@q_id, 'A type of database', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz21_id, 'What is a DDoS attack?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Deleting a database', 0, 0),
  (@q_id, 'Overwhelming a server with traffic to make it unavailable', 1, 1),
  (@q_id, 'Stealing passwords', 0, 2),
  (@q_id, 'Installing a backdoor', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz21_id, 'What is two-factor authentication (2FA)?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Using two passwords', 0, 0),
  (@q_id, 'Combining two security methods to verify identity', 1, 1),
  (@q_id, 'A type of encryption', 0, 2),
  (@q_id, 'A firewall rule', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz21_id, 'What is ransomware?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A network scanner', 0, 0),
  (@q_id, 'Malware that encrypts files and demands payment for decryption', 1, 1),
  (@q_id, 'A firewall', 0, 2),
  (@q_id, 'A type of VPN', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz21_id, 'What is a zero-day vulnerability?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'An old bug', 0, 0),
  (@q_id, 'An unpatched flaw unknown to the software vendor', 1, 1),
  (@q_id, 'A minor bug', 0, 2),
  (@q_id, 'A feature not a bug', 0, 3);

-- End Quiz 21: Cybersecurity Fundamentals

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Cryptography Basics', 'Fundamental concepts of cryptography', 'Cybersecurity', 30, 75.00);
SET @quiz22_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz22_id, 'What is encryption?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Deleting data', 0, 0),
  (@q_id, 'Converting data into unreadable format to protect it', 1, 1),
  (@q_id, 'Compressing data', 0, 2),
  (@q_id, 'Backing up data', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz22_id, 'What does \'symmetric encryption\' mean?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Two different keys are used', 0, 0),
  (@q_id, 'The same key is used for encryption and decryption', 1, 1),
  (@q_id, 'No key is needed', 0, 2),
  (@q_id, 'Public key only', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz22_id, 'What is a public key in asymmetric cryptography?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A secret key', 0, 0),
  (@q_id, 'A key shared openly for others to encrypt data for you', 1, 1),
  (@q_id, 'A password', 0, 2),
  (@q_id, 'A certificate', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz22_id, 'What does SSL/TLS provide?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'File compression', 0, 0),
  (@q_id, 'Encrypted communication over a network', 1, 1),
  (@q_id, 'IP addressing', 0, 2),
  (@q_id, 'Domain name resolution', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz22_id, 'What is a hash function?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of encryption', 0, 0),
  (@q_id, 'A one-way function that converts data to a fixed-size value', 1, 1),
  (@q_id, 'A compression algorithm', 0, 2),
  (@q_id, 'A key exchange method', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz22_id, 'Which hash algorithm is considered most secure today?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'MD5', 0, 0),
  (@q_id, 'SHA-1', 0, 1),
  (@q_id, 'SHA-256', 1, 2),
  (@q_id, 'CRC32', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz22_id, 'What is a digital signature?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A scanned signature', 0, 0),
  (@q_id, 'A cryptographic mechanism to verify authenticity of data', 1, 1),
  (@q_id, 'A type of firewall', 0, 2),
  (@q_id, 'An encryption key', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz22_id, 'What does PKI stand for?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Public Key Infrastructure', 1, 0),
  (@q_id, 'Private Key Interface', 0, 1),
  (@q_id, 'Protocol Key Integration', 0, 2),
  (@q_id, 'Public Knowledge Interface', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz22_id, 'What is a certificate authority (CA)?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A hacker', 0, 0),
  (@q_id, 'A trusted entity that issues digital certificates', 1, 1),
  (@q_id, 'A type of firewall', 0, 2),
  (@q_id, 'An encryption standard', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz22_id, 'What is steganography?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Encrypting data', 0, 0),
  (@q_id, 'Hiding data within another file or image', 1, 1),
  (@q_id, 'A hashing method', 0, 2),
  (@q_id, 'A type of VPN', 0, 3);

-- End Quiz 22: Cryptography Basics

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Network Security', 'Protecting network infrastructure', 'Cybersecurity', 30, 75.00);
SET @quiz23_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz23_id, 'What is an IDS?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Internet Domain Server', 0, 0),
  (@q_id, 'Intrusion Detection System', 1, 1),
  (@q_id, 'Internal Data Store', 0, 2),
  (@q_id, 'Integrated Defense Software', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz23_id, 'What does a DMZ do in network security?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Encrypts all traffic', 0, 0),
  (@q_id, 'Provides a buffer zone between public and private networks', 1, 1),
  (@q_id, 'Assigns IP addresses', 0, 2),
  (@q_id, 'Blocks all external traffic', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz23_id, 'What is port scanning?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Changing port numbers', 0, 0),
  (@q_id, 'Probing a server for open ports', 1, 1),
  (@q_id, 'Installing a firewall', 0, 2),
  (@q_id, 'Encrypting ports', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz23_id, 'What is network segmentation?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Combining networks', 0, 0),
  (@q_id, 'Dividing a network into smaller subnets to limit access', 1, 1),
  (@q_id, 'Encrypting traffic', 0, 2),
  (@q_id, 'Adding more routers', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz23_id, 'What is a man-in-the-middle attack?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Deleting packets', 0, 0),
  (@q_id, 'An attacker intercepts communication between two parties', 1, 1),
  (@q_id, 'A type of virus', 0, 2),
  (@q_id, 'A DDoS variant', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz23_id, 'What is the purpose of a proxy server?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Assign IP addresses', 0, 0),
  (@q_id, 'Act as an intermediary between client and server', 1, 1),
  (@q_id, 'Store passwords', 0, 2),
  (@q_id, 'Encrypt files', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz23_id, 'What does NAT stand for?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Network Address Translation', 1, 0),
  (@q_id, 'Node Access Terminal', 0, 1),
  (@q_id, 'Network Authentication Token', 0, 2),
  (@q_id, 'Normal Address Type', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz23_id, 'What is a honeypot in cybersecurity?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of malware', 0, 0),
  (@q_id, 'A decoy system designed to lure attackers', 1, 1),
  (@q_id, 'A firewall rule', 0, 2),
  (@q_id, 'An IDS system', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz23_id, 'What is the purpose of ACLs in networking?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Assign IP addresses', 0, 0),
  (@q_id, 'Control access to network resources based on rules', 1, 1),
  (@q_id, 'Encrypt traffic', 0, 2),
  (@q_id, 'Compress data', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz23_id, 'What is VLAN?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of VPN', 0, 0),
  (@q_id, 'A logical subdivision of a network at the data link layer', 1, 1),
  (@q_id, 'A wireless protocol', 0, 2),
  (@q_id, 'A routing algorithm', 0, 3);

-- End Quiz 23: Network Security

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Common Cyber Threats', 'Understanding various types of cyber threats', 'Cybersecurity', 30, 75.00);
SET @quiz24_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz24_id, 'What is a Trojan horse in cybersecurity?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of hardware', 0, 0),
  (@q_id, 'Malware disguised as legitimate software', 1, 1),
  (@q_id, 'A firewall bypass', 0, 2),
  (@q_id, 'A network protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz24_id, 'What is a keylogger?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A typing tutor', 0, 0),
  (@q_id, 'Software that records keystrokes to capture passwords', 1, 1),
  (@q_id, 'A network scanner', 0, 2),
  (@q_id, 'A type of firewall', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz24_id, 'What is SQL injection?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A programming technique', 0, 0),
  (@q_id, 'An attack inserting malicious SQL into a query', 1, 1),
  (@q_id, 'A database backup', 0, 2),
  (@q_id, 'A type of hash', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz24_id, 'What is cross-site scripting (XSS)?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A CSS technique', 0, 0),
  (@q_id, 'Injecting malicious scripts into web pages viewed by others', 1, 1),
  (@q_id, 'A PHP framework', 0, 2),
  (@q_id, 'A server attack', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz24_id, 'What is a botnet?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A network of robots', 0, 0),
  (@q_id, 'A network of infected computers controlled by an attacker', 1, 1),
  (@q_id, 'A security tool', 0, 2),
  (@q_id, 'A type of firewall', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz24_id, 'What is spyware?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A debugging tool', 0, 0),
  (@q_id, 'Software that secretly monitors user activity', 1, 1),
  (@q_id, 'A network analyzer', 0, 2),
  (@q_id, 'A type of firewall', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz24_id, 'What is adware?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Anti-virus software', 0, 0),
  (@q_id, 'Software that automatically displays unwanted advertisements', 1, 1),
  (@q_id, 'A type of firewall', 0, 2),
  (@q_id, 'A proxy server', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz24_id, 'What is a rootkit?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of virus', 0, 0),
  (@q_id, 'Malware that gives hackers privileged access while hiding its presence', 1, 1),
  (@q_id, 'A firewall tool', 0, 2),
  (@q_id, 'A network protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz24_id, 'What is pharming?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A phishing email', 0, 0),
  (@q_id, 'Redirecting users to fake websites by modifying DNS', 1, 1),
  (@q_id, 'A DDoS attack', 0, 2),
  (@q_id, 'A type of ransomware', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz24_id, 'What is typosquatting?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A typing error', 0, 0),
  (@q_id, 'Registering misspelled domain names to trick users', 1, 1),
  (@q_id, 'A type of XSS', 0, 2),
  (@q_id, 'A SQL attack', 0, 3);

-- End Quiz 24: Common Cyber Threats

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Ethical Hacking Concepts', 'Introduction to ethical hacking and penetration testing', 'Cybersecurity', 30, 75.00);
SET @quiz25_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz25_id, 'What is ethical hacking?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Hacking without permission', 0, 0),
  (@q_id, 'Authorized testing of systems to find vulnerabilities', 1, 1),
  (@q_id, 'Writing malware', 0, 2),
  (@q_id, 'Bypassing firewalls for fun', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz25_id, 'What is a penetration test?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A software test', 0, 0),
  (@q_id, 'A simulated cyberattack to evaluate security', 1, 1),
  (@q_id, 'A network speed test', 0, 2),
  (@q_id, 'A hardware test', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz25_id, 'What does \'white hat\' hacker mean?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A malicious hacker', 0, 0),
  (@q_id, 'An authorized security professional who finds vulnerabilities', 1, 1),
  (@q_id, 'An anonymous hacker', 0, 2),
  (@q_id, 'A hacker who sells exploits', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz25_id, 'What is reconnaissance in ethical hacking?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Attacking a system', 0, 0),
  (@q_id, 'Gathering information about a target', 1, 1),
  (@q_id, 'Installing malware', 0, 2),
  (@q_id, 'Covering tracks', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz25_id, 'Which tool is widely used for network scanning in penetration testing?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Photoshop', 0, 0),
  (@q_id, 'Microsoft Word', 0, 1),
  (@q_id, 'Nmap', 1, 2),
  (@q_id, 'Excel', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz25_id, 'What is a vulnerability assessment?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Patching systems', 0, 0),
  (@q_id, 'Identifying security weaknesses in a system', 1, 1),
  (@q_id, 'Installing antivirus', 0, 2),
  (@q_id, 'Encrypting data', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz25_id, 'What does \'black hat\' hacker mean?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A certified ethical hacker', 0, 0),
  (@q_id, 'A malicious hacker who exploits systems without authorization', 1, 1),
  (@q_id, 'A beginner hacker', 0, 2),
  (@q_id, 'A government hacker', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz25_id, 'What is Metasploit?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A web browser', 0, 0),
  (@q_id, 'A penetration testing framework', 1, 1),
  (@q_id, 'A firewall', 0, 2),
  (@q_id, 'An antivirus', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz25_id, 'What does \'grey hat\' hacker mean?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Always ethical', 0, 0),
  (@q_id, 'Always malicious', 0, 1),
  (@q_id, 'Between ethical and unethical, may break rules but typically not for malice', 1, 2),
  (@q_id, 'A beginner', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz25_id, 'What is the final phase of ethical hacking?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Reconnaissance', 0, 0),
  (@q_id, 'Exploitation', 0, 1),
  (@q_id, 'Reporting findings to the client', 1, 2),
  (@q_id, 'Covering tracks', 0, 3);

-- End Quiz 25: Ethical Hacking Concepts

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Operating Systems Fundamentals', 'Core concepts of operating systems', 'Operating Systems', 30, 75.00);
SET @quiz26_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz26_id, 'What is an operating system?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A programming language', 0, 0),
  (@q_id, 'Software that manages hardware and software resources', 1, 1),
  (@q_id, 'A network protocol', 0, 2),
  (@q_id, 'A database system', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz26_id, 'What is a process in an OS?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A programming loop', 0, 0),
  (@q_id, 'A running instance of a program', 1, 1),
  (@q_id, 'A type of memory', 0, 2),
  (@q_id, 'A file system', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz26_id, 'What is virtual memory?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'RAM that is very fast', 0, 0),
  (@q_id, 'A technique using disk space as an extension of RAM', 1, 1),
  (@q_id, 'A type of cache', 0, 2),
  (@q_id, 'A cloud storage', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz26_id, 'What is a context switch?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Changing the desktop theme', 0, 0),
  (@q_id, 'Saving the state of a process and loading another', 1, 1),
  (@q_id, 'Shutting down the OS', 0, 2),
  (@q_id, 'Starting a new application', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz26_id, 'What is a kernel?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The outermost layer of OS', 0, 0),
  (@q_id, 'The core of the OS that manages system resources', 1, 1),
  (@q_id, 'A type of process', 0, 2),
  (@q_id, 'A file manager', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz26_id, 'What is multitasking?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Running many programs on many computers', 0, 0),
  (@q_id, 'The ability of an OS to run multiple processes concurrently', 1, 1),
  (@q_id, 'A type of file system', 0, 2),
  (@q_id, 'A network feature', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz26_id, 'What is a device driver?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A hardware component', 0, 0),
  (@q_id, 'Software that allows the OS to communicate with hardware', 1, 1),
  (@q_id, 'A type of file', 0, 2),
  (@q_id, 'A network protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz26_id, 'What is deadlock in OS?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A slow process', 0, 0),
  (@q_id, 'A situation where processes wait for each other indefinitely', 1, 1),
  (@q_id, 'A type of virus', 0, 2),
  (@q_id, 'A file system error', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz26_id, 'What is a thread?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of file', 0, 0),
  (@q_id, 'The smallest unit of execution within a process', 1, 1),
  (@q_id, 'A type of process', 0, 2),
  (@q_id, 'A memory block', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz26_id, 'What is the purpose of an OS scheduler?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Format the hard drive', 0, 0),
  (@q_id, 'Decide which process runs on the CPU at any time', 1, 1),
  (@q_id, 'Manage user accounts', 0, 2),
  (@q_id, 'Handle network connections', 0, 3);

-- End Quiz 26: Operating Systems Fundamentals

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Linux Operating System', 'Introduction to Linux OS and commands', 'Linux', 30, 75.00);
SET @quiz27_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz27_id, 'Which command lists files in a directory in Linux?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'dir', 0, 0),
  (@q_id, 'list', 0, 1),
  (@q_id, 'ls', 1, 2),
  (@q_id, 'show', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz27_id, 'Which command changes the current directory?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'move', 0, 0),
  (@q_id, 'cd', 1, 1),
  (@q_id, 'chdir', 0, 2),
  (@q_id, 'go', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz27_id, 'What does \'chmod\' do in Linux?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Changes file ownership', 0, 0),
  (@q_id, 'Changes file permissions', 1, 1),
  (@q_id, 'Creates a directory', 0, 2),
  (@q_id, 'Moves files', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz27_id, 'Which command displays currently running processes?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'tasklist', 0, 0),
  (@q_id, 'processes', 0, 1),
  (@q_id, 'ps', 1, 2),
  (@q_id, 'proc', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz27_id, 'What is the root directory in Linux?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '/root', 0, 0),
  (@q_id, '/', 1, 1),
  (@q_id, '/home', 0, 2),
  (@q_id, '\', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz27_id, 'Which command creates a new directory?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'create', 0, 0),
  (@q_id, 'newdir', 0, 1),
  (@q_id, 'mkdir', 1, 2),
  (@q_id, 'makedir', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz27_id, 'What does \'grep\' do?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Searches for a pattern in files', 1, 0),
  (@q_id, 'Copies files', 0, 1),
  (@q_id, 'Moves files', 0, 2),
  (@q_id, 'Shows disk usage', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz27_id, 'Which command shows disk usage?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'diskinfo', 0, 0),
  (@q_id, 'df', 1, 1),
  (@q_id, 'du', 0, 2),
  (@q_id, 'Both B and C', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz27_id, 'What is the superuser account called in Linux?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'admin', 0, 0),
  (@q_id, 'administrator', 0, 1),
  (@q_id, 'root', 1, 2),
  (@q_id, 'sudo', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz27_id, 'Which command copies files in Linux?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'move', 0, 0),
  (@q_id, 'cp', 1, 1),
  (@q_id, 'copy', 0, 2),
  (@q_id, 'trans', 0, 3);

-- End Quiz 27: Linux Operating System

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Windows Operating System', 'Windows OS features and administration', 'Operating Systems', 30, 75.00);
SET @quiz28_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz28_id, 'What is the Windows Registry?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A user account database', 0, 0),
  (@q_id, 'A hierarchical database storing OS and application settings', 1, 1),
  (@q_id, 'A type of file system', 0, 2),
  (@q_id, 'A network tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz28_id, 'What does \'Task Manager\' show in Windows?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'File sizes', 0, 0),
  (@q_id, 'Running processes, CPU, and memory usage', 1, 1),
  (@q_id, 'Network configuration', 0, 2),
  (@q_id, 'Installed software', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz28_id, 'Which command opens Command Prompt in Windows search?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'terminal', 0, 0),
  (@q_id, 'bash', 0, 1),
  (@q_id, 'cmd', 1, 2),
  (@q_id, 'shell', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz28_id, 'What is NTFS?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Network Transfer File System', 0, 0),
  (@q_id, 'New Technology File System used by Windows', 1, 1),
  (@q_id, 'Network Task File System', 0, 2),
  (@q_id, 'A type of virus', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz28_id, 'What is Active Directory?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A file browser', 0, 0),
  (@q_id, 'A directory service for managing users and resources in a network', 1, 1),
  (@q_id, 'A type of registry', 0, 2),
  (@q_id, 'A Windows update tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz28_id, 'What does \'ipconfig\' show?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Running processes', 0, 0),
  (@q_id, 'Network interface configuration including IP address', 1, 1),
  (@q_id, 'Installed programs', 0, 2),
  (@q_id, 'Firewall rules', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz28_id, 'What is the Windows Event Viewer used for?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Playing videos', 0, 0),
  (@q_id, 'Viewing system logs and events', 1, 1),
  (@q_id, 'Editing registry', 0, 2),
  (@q_id, 'Managing files', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz28_id, 'What is a Windows service?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A background program that runs without user interaction', 1, 0),
  (@q_id, 'A type of application', 0, 1),
  (@q_id, 'A network protocol', 0, 2),
  (@q_id, 'A file type', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz28_id, 'What does \'msconfig\' do?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Shows network settings', 0, 0),
  (@q_id, 'Configures system startup and boot options', 1, 1),
  (@q_id, 'Shows disk partitions', 0, 2),
  (@q_id, 'Manages user accounts', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz28_id, 'What file system does USB drives typically use?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'NTFS', 0, 0),
  (@q_id, 'ext4', 0, 1),
  (@q_id, 'FAT32 or exFAT', 1, 2),
  (@q_id, 'HFS+', 0, 3);

-- End Quiz 28: Windows Operating System

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Process Management in OS', 'How operating systems manage processes', 'Operating Systems', 30, 75.00);
SET @quiz29_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz29_id, 'What are the main states of a process?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Start, Run, End', 0, 0),
  (@q_id, 'New, Ready, Running, Waiting, Terminated', 1, 1),
  (@q_id, 'Active, Inactive, Sleeping', 0, 2),
  (@q_id, 'Created, Executed, Deleted', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz29_id, 'What is a PCB (Process Control Block)?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A hardware component', 0, 0),
  (@q_id, 'A data structure that stores information about a process', 1, 1),
  (@q_id, 'A type of scheduler', 0, 2),
  (@q_id, 'A memory page', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz29_id, 'What is a zombie process?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A virus', 0, 0),
  (@q_id, 'A process that has finished but its entry still exists in the process table', 1, 1),
  (@q_id, 'A slow process', 0, 2),
  (@q_id, 'A background service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz29_id, 'What is process synchronization?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Running processes faster', 0, 0),
  (@q_id, 'Coordinating processes to share resources without conflict', 1, 1),
  (@q_id, 'Terminating processes', 0, 2),
  (@q_id, 'Scheduling processes', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz29_id, 'What is a semaphore?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of signal', 0, 0),
  (@q_id, 'A synchronization variable used to control access to shared resources', 1, 1),
  (@q_id, 'A process state', 0, 2),
  (@q_id, 'A scheduler algorithm', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz29_id, 'What is the purpose of a mutex?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Speed up processes', 0, 0),
  (@q_id, 'Provide mutual exclusion to prevent concurrent access to a resource', 1, 1),
  (@q_id, 'Schedule processes', 0, 2),
  (@q_id, 'Terminate processes', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz29_id, 'What is the critical section in OS?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The kernel', 0, 0),
  (@q_id, 'A part of code that accesses shared resources and must run atomically', 1, 1),
  (@q_id, 'A type of deadlock', 0, 2),
  (@q_id, 'A scheduler', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz29_id, 'What is starvation in OS?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Disk space running low', 0, 0),
  (@q_id, 'A process waiting indefinitely because others keep getting resources', 1, 1),
  (@q_id, 'A type of deadlock', 0, 2),
  (@q_id, 'Memory overflow', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz29_id, 'Which scheduling algorithm is the simplest?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Round Robin', 0, 0),
  (@q_id, 'Shortest Job First', 0, 1),
  (@q_id, 'First Come First Served', 1, 2),
  (@q_id, 'Priority Scheduling', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz29_id, 'What is preemptive scheduling?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'OS cannot interrupt a running process', 0, 0),
  (@q_id, 'OS can interrupt a running process to give CPU to another', 1, 1),
  (@q_id, 'Processes run in a fixed order', 0, 2),
  (@q_id, 'Only batch processes', 0, 3);

-- End Quiz 29: Process Management in OS

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'File Systems and Storage', 'File systems and storage management in OS', 'Operating Systems', 30, 75.00);
SET @quiz30_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz30_id, 'What is a file system?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of database', 0, 0),
  (@q_id, 'A method for organizing and storing files on a storage device', 1, 1),
  (@q_id, 'A network protocol', 0, 2),
  (@q_id, 'A process manager', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz30_id, 'What does FAT stand for?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'File Allocation Table', 1, 0),
  (@q_id, 'Fast Access Technology', 0, 1),
  (@q_id, 'File Access Transfer', 0, 2),
  (@q_id, 'Fixed Allocation Type', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz30_id, 'What is a file inode in Linux?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A file name', 0, 0),
  (@q_id, 'A data structure that stores metadata about a file', 1, 1),
  (@q_id, 'A directory', 0, 2),
  (@q_id, 'A file permission', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz30_id, 'What is disk partitioning?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Formatting a disk', 0, 0),
  (@q_id, 'Dividing a storage device into separate sections', 1, 1),
  (@q_id, 'Backing up a disk', 0, 2),
  (@q_id, 'Encrypting a disk', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz30_id, 'What does RAID stand for?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Random Access Integrated Disk', 0, 0),
  (@q_id, 'Redundant Array of Independent Disks', 1, 1),
  (@q_id, 'Rapid Array of Integrated Drives', 0, 2),
  (@q_id, 'Redundant Access Interface Drive', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz30_id, 'Which RAID level provides mirroring?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'RAID 0', 0, 0),
  (@q_id, 'RAID 1', 1, 1),
  (@q_id, 'RAID 5', 0, 2),
  (@q_id, 'RAID 6', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz30_id, 'What is a file path?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A file\'s content', 0, 0),
  (@q_id, 'The location of a file in the directory hierarchy', 1, 1),
  (@q_id, 'A file permission', 0, 2),
  (@q_id, 'A file extension', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz30_id, 'What is defragmentation?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Deleting files', 0, 0),
  (@q_id, 'Rearranging fragmented files to improve disk performance', 1, 1),
  (@q_id, 'Formatting the disk', 0, 2),
  (@q_id, 'Encrypting the disk', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz30_id, 'What is the purpose of swap space?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Backing up data', 0, 0),
  (@q_id, 'Extending virtual memory by using disk space', 1, 1),
  (@q_id, 'Caching frequently used files', 0, 2),
  (@q_id, 'Storing OS files', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz30_id, 'What is a symbolic link in Linux?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A copied file', 0, 0),
  (@q_id, 'A reference that points to another file or directory', 1, 1),
  (@q_id, 'A hard link', 0, 2),
  (@q_id, 'A file permission', 0, 3);

-- End Quiz 30: File Systems and Storage

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Data Structures: Arrays and Lists', 'Arrays and linked lists concepts', 'Data Structures', 30, 75.00);
SET @quiz31_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz31_id, 'What is an array?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A dynamic data structure', 0, 0),
  (@q_id, 'A collection of elements stored in contiguous memory', 1, 1),
  (@q_id, 'A type of loop', 0, 2),
  (@q_id, 'A linked list', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz31_id, 'What is the time complexity of accessing an element in an array by index?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'O(n)', 0, 0),
  (@q_id, 'O(log n)', 0, 1),
  (@q_id, 'O(1)', 1, 2),
  (@q_id, 'O(n^2)', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz31_id, 'What is a linked list?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of array', 0, 0),
  (@q_id, 'A sequence of nodes where each node points to the next', 1, 1),
  (@q_id, 'A binary tree', 0, 2),
  (@q_id, 'A hash table', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz31_id, 'What is the advantage of a linked list over an array?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Faster access', 0, 0),
  (@q_id, 'Dynamic size, easy insertion and deletion', 1, 1),
  (@q_id, 'Better memory efficiency', 0, 2),
  (@q_id, 'Fixed size', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz31_id, 'What is a doubly linked list?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A list with two heads', 0, 0),
  (@q_id, 'Each node has pointers to both next and previous nodes', 1, 1),
  (@q_id, 'A sorted list', 0, 2),
  (@q_id, 'A circular list', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz31_id, 'What is the disadvantage of an array?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Cannot store multiple types', 0, 0),
  (@q_id, 'Fixed size, expensive insertions/deletions in the middle', 1, 1),
  (@q_id, 'Slow access by index', 0, 2),
  (@q_id, 'Cannot be sorted', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz31_id, 'What is a circular linked list?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A list with a loop', 0, 0),
  (@q_id, 'The last node points back to the first node', 1, 1),
  (@q_id, 'A doubly linked list', 0, 2),
  (@q_id, 'A sorted list', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz31_id, 'What is the time complexity of searching an unsorted array?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'O(1)', 0, 0),
  (@q_id, 'O(log n)', 0, 1),
  (@q_id, 'O(n)', 1, 2),
  (@q_id, 'O(n^2)', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz31_id, 'What is a sparse array?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'An array with no elements', 0, 0),
  (@q_id, 'An array where most elements are zero or empty', 1, 1),
  (@q_id, 'A sorted array', 0, 2),
  (@q_id, 'A 2D array', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz31_id, 'Which data structure uses LIFO order?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Queue', 0, 0),
  (@q_id, 'Stack', 1, 1),
  (@q_id, 'Linked List', 0, 2),
  (@q_id, 'Deque', 0, 3);

-- End Quiz 31: Data Structures: Arrays and Lists

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Data Structures: Stacks and Queues', 'Understanding stacks and queues', 'Data Structures', 30, 75.00);
SET @quiz32_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz32_id, 'What does LIFO stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Last In First Out', 1, 0),
  (@q_id, 'Last In First Only', 0, 1),
  (@q_id, 'Later In First Out', 0, 2),
  (@q_id, 'Largest In First Out', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz32_id, 'What does FIFO stand for?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'First In First Out', 1, 0),
  (@q_id, 'First Instance First Output', 0, 1),
  (@q_id, 'Fixed In Fixed Output', 0, 2),
  (@q_id, 'First In Final Out', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz32_id, 'Which operation adds an element to a stack?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'enqueue', 0, 0),
  (@q_id, 'push', 1, 1),
  (@q_id, 'insert', 0, 2),
  (@q_id, 'add', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz32_id, 'Which operation removes an element from a stack?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'dequeue', 0, 0),
  (@q_id, 'pop', 1, 1),
  (@q_id, 'remove', 0, 2),
  (@q_id, 'delete', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz32_id, 'What is the top of a stack?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The bottom element', 0, 0),
  (@q_id, 'The first element added', 0, 1),
  (@q_id, 'The most recently added element', 1, 2),
  (@q_id, 'The middle element', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz32_id, 'Which operation adds an element to a queue?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'push', 0, 0),
  (@q_id, 'pop', 0, 1),
  (@q_id, 'enqueue', 1, 2),
  (@q_id, 'dequeue', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz32_id, 'What is a priority queue?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A queue where elements are processed by priority', 1, 0),
  (@q_id, 'A LIFO queue', 0, 1),
  (@q_id, 'A double-ended queue', 0, 2),
  (@q_id, 'A circular queue', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz32_id, 'What is a deque?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of tree', 0, 0),
  (@q_id, 'A double-ended queue allowing insertion/removal from both ends', 1, 1),
  (@q_id, 'A type of stack', 0, 2),
  (@q_id, 'A priority queue', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz32_id, 'What is the time complexity of push and pop on a stack?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'O(n)', 0, 0),
  (@q_id, 'O(log n)', 0, 1),
  (@q_id, 'O(1)', 1, 2),
  (@q_id, 'O(n^2)', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz32_id, 'What is a use case of a stack?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Task scheduling', 0, 0),
  (@q_id, 'Function call management and undo operations', 1, 1),
  (@q_id, 'Printer queue', 0, 2),
  (@q_id, 'Search algorithms', 0, 3);

-- End Quiz 32: Data Structures: Stacks and Queues

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Trees and Binary Trees', 'Tree data structures and traversal methods', 'Data Structures', 30, 75.00);
SET @quiz33_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz33_id, 'What is a tree in data structures?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A linear structure', 0, 0),
  (@q_id, 'A hierarchical structure with a root and child nodes', 1, 1),
  (@q_id, 'A type of graph', 0, 2),
  (@q_id, 'A sorted array', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz33_id, 'What is the root of a tree?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The bottommost node', 0, 0),
  (@q_id, 'The topmost node with no parent', 1, 1),
  (@q_id, 'A leaf node', 0, 2),
  (@q_id, 'A middle node', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz33_id, 'What is a leaf node?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The root node', 0, 0),
  (@q_id, 'A node with children', 0, 1),
  (@q_id, 'A node with no children', 1, 2),
  (@q_id, 'The deepest node always', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz33_id, 'What is a binary tree?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A tree with only one child per node', 0, 0),
  (@q_id, 'A tree where each node has at most two children', 1, 1),
  (@q_id, 'A sorted tree', 0, 2),
  (@q_id, 'A balanced tree', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz33_id, 'What is inorder traversal?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Root → Left → Right', 0, 0),
  (@q_id, 'Left → Root → Right', 1, 1),
  (@q_id, 'Left → Right → Root', 0, 2),
  (@q_id, 'Right → Root → Left', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz33_id, 'What is preorder traversal?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Root → Left → Right', 1, 0),
  (@q_id, 'Left → Root → Right', 0, 1),
  (@q_id, 'Left → Right → Root', 0, 2),
  (@q_id, 'Right → Left → Root', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz33_id, 'What is a Binary Search Tree (BST)?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A tree with random values', 0, 0),
  (@q_id, 'A tree where left < root < right for all nodes', 1, 1),
  (@q_id, 'A balanced binary tree', 0, 2),
  (@q_id, 'A tree used for heaps', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz33_id, 'What is the height of a tree?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Number of nodes', 0, 0),
  (@q_id, 'Number of leaf nodes', 0, 1),
  (@q_id, 'Length of the longest path from root to leaf', 1, 2),
  (@q_id, 'Number of edges', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz33_id, 'What is a complete binary tree?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'All leaves are at the same level', 0, 0),
  (@q_id, 'All levels filled except possibly last, filled left to right', 1, 1),
  (@q_id, 'A tree with only two levels', 0, 2),
  (@q_id, 'A sorted tree', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz33_id, 'What is tree balancing?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Trimming leaf nodes', 0, 0),
  (@q_id, 'Keeping tree height minimal to optimize operations', 1, 1),
  (@q_id, 'Sorting tree nodes', 0, 2),
  (@q_id, 'Removing duplicate nodes', 0, 3);

-- End Quiz 33: Trees and Binary Trees

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Sorting and Searching Algorithms', 'Common sorting and searching techniques', 'Data Structures', 30, 75.00);
SET @quiz34_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz34_id, 'What is the time complexity of Bubble Sort in the worst case?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'O(n)', 0, 0),
  (@q_id, 'O(n log n)', 0, 1),
  (@q_id, 'O(n^2)', 1, 2),
  (@q_id, 'O(log n)', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz34_id, 'Which sorting algorithm is generally fastest for large datasets?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Bubble Sort', 0, 0),
  (@q_id, 'Selection Sort', 0, 1),
  (@q_id, 'Merge Sort', 1, 2),
  (@q_id, 'Insertion Sort', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz34_id, 'What is Binary Search?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A sorting algorithm', 0, 0),
  (@q_id, 'A search algorithm on sorted arrays that halves the search space each step', 1, 1),
  (@q_id, 'A graph algorithm', 0, 2),
  (@q_id, 'A hashing technique', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz34_id, 'What is the time complexity of Binary Search?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'O(n)', 0, 0),
  (@q_id, 'O(n^2)', 0, 1),
  (@q_id, 'O(log n)', 1, 2),
  (@q_id, 'O(1)', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz34_id, 'What does Merge Sort use?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Pivot element', 0, 0),
  (@q_id, 'Divide and conquer strategy', 1, 1),
  (@q_id, 'Bubble comparison', 0, 2),
  (@q_id, 'Direct insertion', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz34_id, 'Which sort algorithm is most efficient for nearly sorted data?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Quick Sort', 0, 0),
  (@q_id, 'Merge Sort', 0, 1),
  (@q_id, 'Insertion Sort', 1, 2),
  (@q_id, 'Heap Sort', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz34_id, 'What is the worst-case time complexity of Quick Sort?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'O(n log n)', 0, 0),
  (@q_id, 'O(n)', 0, 1),
  (@q_id, 'O(n^2)', 1, 2),
  (@q_id, 'O(log n)', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz34_id, 'What is a stable sorting algorithm?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'One that runs in constant time', 0, 0),
  (@q_id, 'One that preserves the relative order of equal elements', 1, 1),
  (@q_id, 'One that works on linked lists', 0, 2),
  (@q_id, 'One that uses recursion', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz34_id, 'What is the best case time complexity of Bubble Sort?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'O(n^2)', 0, 0),
  (@q_id, 'O(n log n)', 0, 1),
  (@q_id, 'O(n)', 1, 2),
  (@q_id, 'O(1)', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz34_id, 'What is Heap Sort?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A sort using a queue', 0, 0),
  (@q_id, 'A sort using a binary heap data structure', 1, 1),
  (@q_id, 'A sort using arrays only', 0, 2),
  (@q_id, 'A stable sort', 0, 3);

-- End Quiz 34: Sorting and Searching Algorithms

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Graphs and Graph Algorithms', 'Graph data structures and algorithms', 'Data Structures', 30, 75.00);
SET @quiz35_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz35_id, 'What is a graph in data structures?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A chart', 0, 0),
  (@q_id, 'A collection of vertices connected by edges', 1, 1),
  (@q_id, 'A type of tree', 0, 2),
  (@q_id, 'A sorted list', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz35_id, 'What is the difference between directed and undirected graphs?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Directed graphs have weights', 0, 0),
  (@q_id, 'In directed graphs edges have direction, undirected edges do not', 1, 1),
  (@q_id, 'Undirected graphs have cycles', 0, 2),
  (@q_id, 'Directed graphs are always trees', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz35_id, 'What is BFS?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Binary First Search', 0, 0),
  (@q_id, 'Breadth-First Search, exploring level by level', 1, 1),
  (@q_id, 'Best First Search', 0, 2),
  (@q_id, 'Backtracking First Search', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz35_id, 'What is DFS?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Direct File System', 0, 0),
  (@q_id, 'Depth-First Search, exploring as deep as possible first', 1, 1),
  (@q_id, 'Default File Search', 0, 2),
  (@q_id, 'Data Format System', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz35_id, 'What is Dijkstra\'s algorithm used for?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Sorting nodes', 0, 0),
  (@q_id, 'Finding the shortest path between nodes in a weighted graph', 1, 1),
  (@q_id, 'Detecting cycles', 0, 2),
  (@q_id, 'Tree traversal', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz35_id, 'What is a weighted graph?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A graph with colored nodes', 0, 0),
  (@q_id, 'A graph where edges have associated costs', 1, 1),
  (@q_id, 'A graph with many vertices', 0, 2),
  (@q_id, 'A circular graph', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz35_id, 'What is a cycle in a graph?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A path that visits all nodes', 0, 0),
  (@q_id, 'A path that starts and ends at the same vertex', 1, 1),
  (@q_id, 'A tree structure', 0, 2),
  (@q_id, 'A disconnected component', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz35_id, 'What is a spanning tree?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A tree that includes all vertices with minimum edges', 1, 0),
  (@q_id, 'A subtree', 0, 1),
  (@q_id, 'A balanced tree', 0, 2),
  (@q_id, 'A binary tree', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz35_id, 'What does adjacency matrix represent?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A list of edges', 0, 0),
  (@q_id, 'A 2D matrix showing connections between all vertex pairs', 1, 1),
  (@q_id, 'A heap structure', 0, 2),
  (@q_id, 'A hash table', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz35_id, 'What is a topological sort?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Sorting graph weights', 0, 0),
  (@q_id, 'Linear ordering of vertices such that all edges go from left to right', 1, 1),
  (@q_id, 'Sorting by degree', 0, 2),
  (@q_id, 'Random ordering', 0, 3);

-- End Quiz 35: Graphs and Graph Algorithms

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Software Engineering Principles', 'Core principles of software engineering', 'Software Engineering', 30, 75.00);
SET @quiz36_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz36_id, 'What does SDLC stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Software Development Life Cycle', 1, 0),
  (@q_id, 'System Design and Launch Control', 0, 1),
  (@q_id, 'Software Design Logic Component', 0, 2),
  (@q_id, 'System Development and Launch Cycle', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz36_id, 'What is a software requirement?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A bug report', 0, 0),
  (@q_id, 'A description of what a system should do', 1, 1),
  (@q_id, 'A code comment', 0, 2),
  (@q_id, 'A test case', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz36_id, 'What is the purpose of code review?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Delete unused code', 0, 0),
  (@q_id, 'Check code quality, find bugs, and share knowledge', 1, 1),
  (@q_id, 'Compile code', 0, 2),
  (@q_id, 'Run test cases', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz36_id, 'What is version control?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Tracking software licenses', 0, 0),
  (@q_id, 'Managing changes to code over time', 1, 1),
  (@q_id, 'Compiling different versions', 0, 2),
  (@q_id, 'Counting software users', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz36_id, 'What is refactoring?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Rewriting code from scratch', 0, 0),
  (@q_id, 'Improving code structure without changing its behavior', 1, 1),
  (@q_id, 'Adding new features', 0, 2),
  (@q_id, 'Fixing critical bugs', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz36_id, 'What is a software prototype?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Final product', 0, 0),
  (@q_id, 'An early working model of a system to validate requirements', 1, 1),
  (@q_id, 'A test case', 0, 2),
  (@q_id, 'A deployment package', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz36_id, 'What is technical debt?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A software license cost', 0, 0),
  (@q_id, 'The implied cost of shortcuts taken in code that will need fixing later', 1, 1),
  (@q_id, 'Hardware cost', 0, 2),
  (@q_id, 'Maintenance fee', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz36_id, 'What is software architecture?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The UI design', 0, 0),
  (@q_id, 'The high-level structure and design decisions of a system', 1, 1),
  (@q_id, 'A programming language', 0, 2),
  (@q_id, 'A testing method', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz36_id, 'What is the purpose of documentation?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Slowing development', 0, 0),
  (@q_id, 'Providing information about code, systems, and processes for users and developers', 1, 1),
  (@q_id, 'Replacing testing', 0, 2),
  (@q_id, 'Billing clients', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz36_id, 'What is continuous integration (CI)?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Deploying software continuously', 0, 0),
  (@q_id, 'Automatically building and testing code when changes are pushed', 1, 1),
  (@q_id, 'Writing code continuously', 0, 2),
  (@q_id, 'Integrating databases continuously', 0, 3);

-- End Quiz 36: Software Engineering Principles

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Agile and Scrum', 'Agile methodology and Scrum framework', 'Software Engineering', 30, 75.00);
SET @quiz37_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz37_id, 'What is Agile software development?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A waterfall method', 0, 0),
  (@q_id, 'An iterative approach to software development focused on collaboration', 1, 1),
  (@q_id, 'A strict documentation process', 0, 2),
  (@q_id, 'A testing framework', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz37_id, 'What is a Sprint in Scrum?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A performance test', 0, 0),
  (@q_id, 'A time-boxed iteration of work, typically 1-4 weeks', 1, 1),
  (@q_id, 'A team meeting', 0, 2),
  (@q_id, 'A code review', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz37_id, 'Who is the Scrum Master?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The project owner', 0, 0),
  (@q_id, 'A team member who facilitates Scrum and removes obstacles', 1, 1),
  (@q_id, 'The lead developer', 0, 2),
  (@q_id, 'The client', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz37_id, 'What is a Product Backlog?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A list of bugs', 0, 0),
  (@q_id, 'A prioritized list of features and requirements for a product', 1, 1),
  (@q_id, 'A sprint report', 0, 2),
  (@q_id, 'A team roster', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz37_id, 'What is the Daily Standup in Scrum?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A weekly report', 0, 0),
  (@q_id, 'A short daily meeting to discuss progress and blockers', 1, 1),
  (@q_id, 'A performance review', 0, 2),
  (@q_id, 'A code review', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz37_id, 'What is a Sprint Retrospective?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A product demo', 0, 0),
  (@q_id, 'A meeting to reflect on the sprint and improve the process', 1, 1),
  (@q_id, 'A backlog update', 0, 2),
  (@q_id, 'A client presentation', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz37_id, 'What is velocity in Agile?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Speed of servers', 0, 0),
  (@q_id, 'The amount of work a team can complete in a sprint', 1, 1),
  (@q_id, 'Code quality metric', 0, 2),
  (@q_id, 'Test coverage', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz37_id, 'What is a user story?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A blog post', 0, 0),
  (@q_id, 'A short description of a feature from the user\'s perspective', 1, 1),
  (@q_id, 'A test case', 0, 2),
  (@q_id, 'A bug report', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz37_id, 'What is Kanban?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of database', 0, 0),
  (@q_id, 'A visual workflow management method using cards and boards', 1, 1),
  (@q_id, 'A programming method', 0, 2),
  (@q_id, 'A testing framework', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz37_id, 'What does MVP stand for in Agile?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Most Valuable Player', 0, 0),
  (@q_id, 'Minimum Viable Product', 1, 1),
  (@q_id, 'Maximum Value Pipeline', 0, 2),
  (@q_id, 'Minimum Version Production', 0, 3);

-- End Quiz 37: Agile and Scrum

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Software Testing', 'Types and methods of software testing', 'Software Engineering', 30, 75.00);
SET @quiz38_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz38_id, 'What is unit testing?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Testing the entire application', 0, 0),
  (@q_id, 'Testing individual components or functions in isolation', 1, 1),
  (@q_id, 'Testing network performance', 0, 2),
  (@q_id, 'Testing the user interface', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz38_id, 'What is integration testing?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Testing individual functions', 0, 0),
  (@q_id, 'Testing how multiple modules work together', 1, 1),
  (@q_id, 'Testing security', 0, 2),
  (@q_id, 'Testing performance', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz38_id, 'What is regression testing?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Testing new features', 0, 0),
  (@q_id, 'Retesting to ensure existing features still work after changes', 1, 1),
  (@q_id, 'Testing database queries', 0, 2),
  (@q_id, 'Load testing', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz38_id, 'What is a test case?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A bug report', 0, 0),
  (@q_id, 'A set of conditions to verify that a system works correctly', 1, 1),
  (@q_id, 'A code review', 0, 2),
  (@q_id, 'A deployment step', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz38_id, 'What is black-box testing?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Testing internal code structure', 0, 0),
  (@q_id, 'Testing without knowledge of internal implementation', 1, 1),
  (@q_id, 'Testing dark mode UI', 0, 2),
  (@q_id, 'A type of security test', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz38_id, 'What is white-box testing?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Testing UI colors', 0, 0),
  (@q_id, 'Testing with full knowledge of internal code structure', 1, 1),
  (@q_id, 'A type of user testing', 0, 2),
  (@q_id, 'A performance test', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz38_id, 'What does TDD stand for?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Test-Driven Development', 1, 0),
  (@q_id, 'Total Development Design', 0, 1),
  (@q_id, 'Test-Deployment Documentation', 0, 2),
  (@q_id, 'Technical Design Document', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz38_id, 'What is a bug?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A feature', 0, 0),
  (@q_id, 'A defect or error in software that causes incorrect behavior', 1, 1),
  (@q_id, 'A type of test', 0, 2),
  (@q_id, 'A requirement', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz38_id, 'What is performance testing?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Testing for bugs', 0, 0),
  (@q_id, 'Evaluating how a system performs under a workload', 1, 1),
  (@q_id, 'Testing security', 0, 2),
  (@q_id, 'Testing UI', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz38_id, 'What is UAT?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Unit Acceptance Testing', 0, 0),
  (@q_id, 'User Acceptance Testing where real users validate the system', 1, 1),
  (@q_id, 'User Application Test', 0, 2),
  (@q_id, 'Unified Acceptance Testing', 0, 3);

-- End Quiz 38: Software Testing

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Design Patterns', 'Common software design patterns', 'Software Engineering', 30, 75.00);
SET @quiz39_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz39_id, 'What is a design pattern?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A UI template', 0, 0),
  (@q_id, 'A reusable solution to a commonly occurring problem in software design', 1, 1),
  (@q_id, 'A type of algorithm', 0, 2),
  (@q_id, 'A programming language', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz39_id, 'What category does the Singleton pattern belong to?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Structural', 0, 0),
  (@q_id, 'Behavioral', 0, 1),
  (@q_id, 'Creational', 1, 2),
  (@q_id, 'Architectural', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz39_id, 'What does the Singleton pattern ensure?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A class can be subclassed', 0, 0),
  (@q_id, 'Only one instance of a class exists', 1, 1),
  (@q_id, 'A class cannot be modified', 0, 2),
  (@q_id, 'Multiple instances always', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz39_id, 'What is the Observer pattern?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'An object that observes hardware', 0, 0),
  (@q_id, 'A pattern where objects are notified of state changes in another object', 1, 1),
  (@q_id, 'A type of loop', 0, 2),
  (@q_id, 'A sorting algorithm', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz39_id, 'What is the Factory pattern?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A method to create objects without specifying the exact class', 1, 0),
  (@q_id, 'A design for factories', 0, 1),
  (@q_id, 'A type of inheritance', 0, 2),
  (@q_id, 'A singleton variant', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz39_id, 'What is the MVC pattern?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Model View Controller — a pattern separating data, UI, and logic', 1, 0),
  (@q_id, 'Most Valuable Component', 0, 1),
  (@q_id, 'Mobile View Controller', 0, 2),
  (@q_id, 'Minimum Viable Component', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz39_id, 'What is the Decorator pattern?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Adding comments to code', 0, 0),
  (@q_id, 'Dynamically adding behavior to an object without modifying its class', 1, 1),
  (@q_id, 'A UI component', 0, 2),
  (@q_id, 'A type of inheritance', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz39_id, 'What is the Strategy pattern?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A game strategy', 0, 0),
  (@q_id, 'Defining a family of algorithms and making them interchangeable', 1, 1),
  (@q_id, 'A type of factory', 0, 2),
  (@q_id, 'A structural pattern', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz39_id, 'What category does the Adapter pattern belong to?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Creational', 0, 0),
  (@q_id, 'Behavioral', 0, 1),
  (@q_id, 'Structural', 1, 2),
  (@q_id, 'Architectural', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz39_id, 'What is the purpose of the Facade pattern?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Hide implementation details and provide a simplified interface to a subsystem', 1, 0),
  (@q_id, 'Create objects', 0, 1),
  (@q_id, 'Observe changes', 0, 2),
  (@q_id, 'Sort objects', 0, 3);

-- End Quiz 39: Design Patterns

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'UML and System Design', 'UML diagrams and system design concepts', 'Software Engineering', 30, 75.00);
SET @quiz40_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz40_id, 'What does UML stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Unified Modeling Language', 1, 0),
  (@q_id, 'Universal Markup Language', 0, 1),
  (@q_id, 'Unified Management Layer', 0, 2),
  (@q_id, 'User Markup Logic', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz40_id, 'What does a use case diagram show?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Database relationships', 0, 0),
  (@q_id, 'Interactions between users and the system', 1, 1),
  (@q_id, 'Class relationships', 0, 2),
  (@q_id, 'Sequence of operations', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz40_id, 'What is a class diagram?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A hierarchy of users', 0, 0),
  (@q_id, 'A diagram showing classes, attributes, methods, and relationships', 1, 1),
  (@q_id, 'A use case diagram', 0, 2),
  (@q_id, 'A flow chart', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz40_id, 'What does a sequence diagram show?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Class hierarchy', 0, 0),
  (@q_id, 'The order of messages exchanged between objects over time', 1, 1),
  (@q_id, 'Database schema', 0, 2),
  (@q_id, 'Network topology', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz40_id, 'What is an entity-relationship (ER) diagram?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A class diagram', 0, 0),
  (@q_id, 'A diagram showing entities and relationships in a database', 1, 1),
  (@q_id, 'A network diagram', 0, 2),
  (@q_id, 'A UML class diagram', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz40_id, 'What does \'composition\' mean in UML?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A weak relationship', 0, 0),
  (@q_id, 'A strong relationship where parts cannot exist without the whole', 1, 1),
  (@q_id, 'A type of inheritance', 0, 2),
  (@q_id, 'An interface implementation', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz40_id, 'What is aggregation in UML?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A strong ownership relationship', 0, 0),
  (@q_id, 'A weak relationship where parts can exist independently', 1, 1),
  (@q_id, 'A type of dependency', 0, 2),
  (@q_id, 'An interface', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz40_id, 'What is a state diagram?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Shows class hierarchy', 0, 0),
  (@q_id, 'Shows the states an object can be in and transitions between them', 1, 1),
  (@q_id, 'Shows data flow', 0, 2),
  (@q_id, 'Shows network connections', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz40_id, 'What is a deployment diagram?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Shows class relationships', 0, 0),
  (@q_id, 'Shows how software is deployed to hardware', 1, 1),
  (@q_id, 'Shows user interactions', 0, 2),
  (@q_id, 'Shows data flow', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz40_id, 'What does \'inheritance\' represent in a class diagram?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'An object containing another', 0, 0),
  (@q_id, 'A subclass inheriting properties from a superclass', 1, 1),
  (@q_id, 'A dependency', 0, 2),
  (@q_id, 'An interface', 0, 3);

-- End Quiz 40: UML and System Design

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Cloud Computing Fundamentals', 'Introduction to cloud computing concepts', 'Cloud Computing', 30, 75.00);
SET @quiz41_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz41_id, 'What is cloud computing?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of network cable', 0, 0),
  (@q_id, 'Delivery of computing services over the internet', 1, 1),
  (@q_id, 'A programming language', 0, 2),
  (@q_id, 'An operating system', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz41_id, 'What does IaaS stand for?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Internet as a Service', 0, 0),
  (@q_id, 'Infrastructure as a Service', 1, 1),
  (@q_id, 'Integration as a Service', 0, 2),
  (@q_id, 'Internal as a Service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz41_id, 'What does SaaS stand for?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Software as a Service', 1, 0),
  (@q_id, 'Storage as a Service', 0, 1),
  (@q_id, 'Security as a Service', 0, 2),
  (@q_id, 'Server as a Service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz41_id, 'What does PaaS stand for?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Platform as a Service', 1, 0),
  (@q_id, 'Protocol as a Service', 0, 1),
  (@q_id, 'Processing as a Service', 0, 2),
  (@q_id, 'Proxy as a Service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz41_id, 'What is a public cloud?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A private server', 0, 0),
  (@q_id, 'Cloud services offered over the public internet by a provider', 1, 1),
  (@q_id, 'An on-premises solution', 0, 2),
  (@q_id, 'A hybrid model', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz41_id, 'What is a private cloud?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A cloud only for one organization\'s use', 1, 0),
  (@q_id, 'A shared cloud', 0, 1),
  (@q_id, 'A public cloud', 0, 2),
  (@q_id, 'A third-party cloud', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz41_id, 'What is a hybrid cloud?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A mix of public and private cloud', 1, 0),
  (@q_id, 'A type of database', 0, 1),
  (@q_id, 'A cloud made of multiple providers', 0, 2),
  (@q_id, 'A containerization platform', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz41_id, 'What is elasticity in cloud computing?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Network flexibility', 0, 0),
  (@q_id, 'The ability to scale resources up or down based on demand', 1, 1),
  (@q_id, 'Backup capability', 0, 2),
  (@q_id, 'Data encryption', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz41_id, 'What is a CDN?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Cloud Data Network', 0, 0),
  (@q_id, 'Content Delivery Network distributing content geographically', 1, 1),
  (@q_id, 'Cloud Development Network', 0, 2),
  (@q_id, 'Central Data Node', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz41_id, 'What does TCO mean in cloud context?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Total Cloud Operations', 0, 0),
  (@q_id, 'Total Cost of Ownership', 1, 1),
  (@q_id, 'Transfer Cost of Operations', 0, 2),
  (@q_id, 'Technical Cloud Output', 0, 3);

-- End Quiz 41: Cloud Computing Fundamentals

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'AWS Cloud Services', 'Amazon Web Services core services', 'Cloud Computing', 30, 75.00);
SET @quiz42_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz42_id, 'What does AWS stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Advanced Web Services', 0, 0),
  (@q_id, 'Amazon Web Services', 1, 1),
  (@q_id, 'Automated Web System', 0, 2),
  (@q_id, 'Application Web Server', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz42_id, 'What is Amazon EC2?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A storage service', 0, 0),
  (@q_id, 'A virtual machine (compute) service', 1, 1),
  (@q_id, 'A database service', 0, 2),
  (@q_id, 'A networking service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz42_id, 'What is Amazon S3?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A compute service', 0, 0),
  (@q_id, 'A scalable object storage service', 1, 1),
  (@q_id, 'A database', 0, 2),
  (@q_id, 'A networking tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz42_id, 'What is AWS Lambda?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A server service', 0, 0),
  (@q_id, 'A serverless compute service running code in response to events', 1, 1),
  (@q_id, 'A database', 0, 2),
  (@q_id, 'A CDN', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz42_id, 'What is Amazon RDS?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A compute service', 0, 0),
  (@q_id, 'A managed relational database service', 1, 1),
  (@q_id, 'A storage service', 0, 2),
  (@q_id, 'A networking tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz42_id, 'What is a VPC in AWS?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Virtual Private Cloud — an isolated virtual network', 1, 0),
  (@q_id, 'A type of compute instance', 0, 1),
  (@q_id, 'A storage bucket', 0, 2),
  (@q_id, 'A monitoring service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz42_id, 'What is AWS IAM?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A compute service', 0, 0),
  (@q_id, 'Identity and Access Management for controlling access to AWS resources', 1, 1),
  (@q_id, 'A database', 0, 2),
  (@q_id, 'A storage service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz42_id, 'What is Amazon CloudFront?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A compute service', 0, 0),
  (@q_id, 'A CDN distributing content globally', 1, 1),
  (@q_id, 'A database', 0, 2),
  (@q_id, 'A load balancer', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz42_id, 'What is auto scaling in AWS?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Manually adding servers', 0, 0),
  (@q_id, 'Automatically adjusting compute capacity based on demand', 1, 1),
  (@q_id, 'A backup feature', 0, 2),
  (@q_id, 'A monitoring tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz42_id, 'What is the AWS Shared Responsibility Model?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'AWS handles everything', 0, 0),
  (@q_id, 'AWS secures the cloud infrastructure; customers secure what\'s in the cloud', 1, 1),
  (@q_id, 'Customers handle everything', 0, 2),
  (@q_id, 'A billing model', 0, 3);

-- End Quiz 42: AWS Cloud Services

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Docker and Containerization', 'Docker containers and containerization concepts', 'Cloud Computing', 30, 75.00);
SET @quiz43_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz43_id, 'What is Docker?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A virtual machine', 0, 0),
  (@q_id, 'A platform for developing and running applications in containers', 1, 1),
  (@q_id, 'A programming language', 0, 2),
  (@q_id, 'A cloud provider', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz43_id, 'What is a container?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A virtual machine', 0, 0),
  (@q_id, 'A lightweight, isolated environment for running applications', 1, 1),
  (@q_id, 'A physical server', 0, 2),
  (@q_id, 'A database', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz43_id, 'What is the difference between a container and a VM?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Containers are slower', 0, 0),
  (@q_id, 'Containers share the host OS kernel; VMs include a full OS', 1, 1),
  (@q_id, 'Containers use more resources', 0, 2),
  (@q_id, 'VMs are faster to start', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz43_id, 'What is a Docker image?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A running container', 0, 0),
  (@q_id, 'A read-only template used to create containers', 1, 1),
  (@q_id, 'A virtual machine snapshot', 0, 2),
  (@q_id, 'A configuration file', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz43_id, 'What is a Dockerfile?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A Docker GUI', 0, 0),
  (@q_id, 'A script with instructions to build a Docker image', 1, 1),
  (@q_id, 'A container', 0, 2),
  (@q_id, 'A network config', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz43_id, 'Which command builds a Docker image?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'docker run', 0, 0),
  (@q_id, 'docker build', 1, 1),
  (@q_id, 'docker pull', 0, 2),
  (@q_id, 'docker start', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz43_id, 'Which command runs a Docker container?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'docker build', 0, 0),
  (@q_id, 'docker start', 0, 1),
  (@q_id, 'docker run', 1, 2),
  (@q_id, 'docker exec', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz43_id, 'What is Docker Hub?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A local registry', 0, 0),
  (@q_id, 'A public registry for Docker images', 1, 1),
  (@q_id, 'A container orchestrator', 0, 2),
  (@q_id, 'A monitoring tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz43_id, 'What is Docker Compose?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A single container tool', 0, 0),
  (@q_id, 'A tool for defining and running multi-container Docker apps', 1, 1),
  (@q_id, 'A Docker command', 0, 2),
  (@q_id, 'An image registry', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz43_id, 'What is a Docker volume?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A network setting', 0, 0),
  (@q_id, 'Persistent storage that containers can use', 1, 1),
  (@q_id, 'A container image', 0, 2),
  (@q_id, 'A Dockerfile instruction', 0, 3);

-- End Quiz 43: Docker and Containerization

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Kubernetes Orchestration', 'Kubernetes container orchestration basics', 'Cloud Computing', 30, 75.00);
SET @quiz44_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz44_id, 'What is Kubernetes?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A programming language', 0, 0),
  (@q_id, 'A container orchestration system for automating deployment and scaling', 1, 1),
  (@q_id, 'A cloud provider', 0, 2),
  (@q_id, 'A Docker alternative', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz44_id, 'What is a Pod in Kubernetes?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A virtual machine', 0, 0),
  (@q_id, 'The smallest deployable unit containing one or more containers', 1, 1),
  (@q_id, 'A service', 0, 2),
  (@q_id, 'A namespace', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz44_id, 'What is a Kubernetes Node?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A container', 0, 0),
  (@q_id, 'A worker machine where Pods run', 1, 1),
  (@q_id, 'A Pod group', 0, 2),
  (@q_id, 'A namespace', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz44_id, 'What is a Kubernetes Deployment?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A service', 0, 0),
  (@q_id, 'A resource managing the desired state of a set of Pods', 1, 1),
  (@q_id, 'A Pod', 0, 2),
  (@q_id, 'A namespace', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz44_id, 'What is a Kubernetes Service?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A Pod group', 0, 0),
  (@q_id, 'A stable endpoint to access a set of Pods', 1, 1),
  (@q_id, 'A deployment type', 0, 2),
  (@q_id, 'A namespace', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz44_id, 'What does \'kubectl\' do?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Builds Docker images', 0, 0),
  (@q_id, 'A command-line tool for interacting with Kubernetes clusters', 1, 1),
  (@q_id, 'Creates Docker containers', 0, 2),
  (@q_id, 'A monitoring tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz44_id, 'What is a Kubernetes Namespace?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of Pod', 0, 0),
  (@q_id, 'A logical partition to isolate resources within a cluster', 1, 1),
  (@q_id, 'A network plugin', 0, 2),
  (@q_id, 'A storage type', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz44_id, 'What is a ConfigMap in Kubernetes?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A network config', 0, 0),
  (@q_id, 'A way to store non-sensitive configuration data', 1, 1),
  (@q_id, 'An image registry', 0, 2),
  (@q_id, 'A type of Pod', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz44_id, 'What is Helm in Kubernetes?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A monitoring tool', 0, 0),
  (@q_id, 'A package manager for Kubernetes applications', 1, 1),
  (@q_id, 'A network plugin', 0, 2),
  (@q_id, 'A type of Pod', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz44_id, 'What is horizontal pod autoscaling?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Manually adding Pods', 0, 0),
  (@q_id, 'Automatically adjusting the number of Pods based on load', 1, 1),
  (@q_id, 'Scaling storage', 0, 2),
  (@q_id, 'Network load balancing', 0, 3);

-- End Quiz 44: Kubernetes Orchestration

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Serverless Computing', 'Serverless architecture and concepts', 'Cloud Computing', 30, 75.00);
SET @quiz45_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz45_id, 'What is serverless computing?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'No servers exist', 0, 0),
  (@q_id, 'Code is executed without managing server infrastructure', 1, 1),
  (@q_id, 'A type of VM', 0, 2),
  (@q_id, 'A local computing model', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz45_id, 'What is a key benefit of serverless?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Always faster', 0, 0),
  (@q_id, 'Pay only for actual execution time, no idle cost', 1, 1),
  (@q_id, 'No internet needed', 0, 2),
  (@q_id, 'Fixed pricing', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz45_id, 'What is AWS Lambda?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A server management tool', 0, 0),
  (@q_id, 'A serverless function execution service from AWS', 1, 1),
  (@q_id, 'A database', 0, 2),
  (@q_id, 'A container service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz45_id, 'What is a cold start in serverless?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A server shutdown', 0, 0),
  (@q_id, 'The latency when a function is invoked for the first time', 1, 1),
  (@q_id, 'A network timeout', 0, 2),
  (@q_id, 'A database connection error', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz45_id, 'What is FaaS?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'File as a Service', 0, 0),
  (@q_id, 'Function as a Service — running individual functions on demand', 1, 1),
  (@q_id, 'Framework as a Service', 0, 2),
  (@q_id, 'Firewall as a Service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz45_id, 'What triggers an AWS Lambda function?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Only manual triggers', 0, 0),
  (@q_id, 'Events like HTTP requests, file uploads, database changes, and more', 1, 1),
  (@q_id, 'Only database events', 0, 2),
  (@q_id, 'Only scheduled events', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz45_id, 'What is the maximum execution time for an AWS Lambda function?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '1 minute', 0, 0),
  (@q_id, '5 minutes', 0, 1),
  (@q_id, '15 minutes', 1, 2),
  (@q_id, '1 hour', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz45_id, 'What is serverless framework?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A cloud provider', 0, 0),
  (@q_id, 'An open-source tool for deploying serverless applications', 1, 1),
  (@q_id, 'A type of database', 0, 2),
  (@q_id, 'A container tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz45_id, 'What language does AWS Lambda NOT natively support?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Python', 0, 0),
  (@q_id, 'Node.js', 0, 1),
  (@q_id, 'COBOL', 1, 2),
  (@q_id, 'Java', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz45_id, 'What is the event-driven architecture?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A sequential code execution model', 0, 0),
  (@q_id, 'A model where events trigger functions or services', 1, 1),
  (@q_id, 'A database design', 0, 2),
  (@q_id, 'A UI pattern', 0, 3);

-- End Quiz 45: Serverless Computing

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Artificial Intelligence Fundamentals', 'Introduction to artificial intelligence concepts', 'AI/ML', 30, 75.00);
SET @quiz46_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz46_id, 'What is Artificial Intelligence?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of robot', 0, 0),
  (@q_id, 'The simulation of human intelligence processes by machines', 1, 1),
  (@q_id, 'A programming language', 0, 2),
  (@q_id, 'A database system', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz46_id, 'What is machine learning?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of robot', 0, 0),
  (@q_id, 'A subset of AI that allows systems to learn from data', 1, 1),
  (@q_id, 'A programming language', 0, 2),
  (@q_id, 'A network protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz46_id, 'What is a neural network?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A social network', 0, 0),
  (@q_id, 'A system of algorithms modeled after the human brain', 1, 1),
  (@q_id, 'A type of database', 0, 2),
  (@q_id, 'A network cable', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz46_id, 'What is supervised learning?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Learning without labels', 0, 0),
  (@q_id, 'Learning from labeled training data', 1, 1),
  (@q_id, 'Learning by reinforcement', 0, 2),
  (@q_id, 'Unsupervised learning', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz46_id, 'What is unsupervised learning?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Learning from labeled data', 0, 0),
  (@q_id, 'Finding patterns in unlabeled data', 1, 1),
  (@q_id, 'Reinforcement learning', 0, 2),
  (@q_id, 'A type of classifier', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz46_id, 'What is reinforcement learning?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Learning from labeled data', 0, 0),
  (@q_id, 'Learning by receiving rewards or penalties for actions', 1, 1),
  (@q_id, 'Supervised learning', 0, 2),
  (@q_id, 'A type of clustering', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz46_id, 'What is overfitting in ML?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Model performs well on all data', 0, 0),
  (@q_id, 'Model performs well on training data but poorly on new data', 1, 1),
  (@q_id, 'Model is too simple', 0, 2),
  (@q_id, 'Model has too little data', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz46_id, 'What is a training dataset?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The final output', 0, 0),
  (@q_id, 'Data used to train a machine learning model', 1, 1),
  (@q_id, 'Test data', 0, 2),
  (@q_id, 'Validation data', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz46_id, 'What is a classification task in ML?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Predicting a number', 0, 0),
  (@q_id, 'Assigning a label to input data from predefined categories', 1, 1),
  (@q_id, 'Clustering data', 0, 2),
  (@q_id, 'Generating text', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz46_id, 'What is a regression task in ML?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Predicting categories', 0, 0),
  (@q_id, 'Predicting a continuous numerical value', 1, 1),
  (@q_id, 'Clustering data', 0, 2),
  (@q_id, 'Generating images', 0, 3);

-- End Quiz 46: Artificial Intelligence Fundamentals

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Machine Learning Algorithms', 'Common machine learning algorithms', 'AI/ML', 30, 75.00);
SET @quiz47_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz47_id, 'What is a decision tree?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of neural network', 0, 0),
  (@q_id, 'A tree-like model making decisions based on feature values', 1, 1),
  (@q_id, 'A clustering algorithm', 0, 2),
  (@q_id, 'A regression model', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz47_id, 'What is the k-Nearest Neighbors (kNN) algorithm?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A deep learning model', 0, 0),
  (@q_id, 'Classifying data by finding the k closest training examples', 1, 1),
  (@q_id, 'A type of neural network', 0, 2),
  (@q_id, 'A clustering algorithm', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz47_id, 'What is k-means clustering?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A classification algorithm', 0, 0),
  (@q_id, 'An algorithm grouping data into k clusters by minimizing variance', 1, 1),
  (@q_id, 'A regression method', 0, 2),
  (@q_id, 'A type of decision tree', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz47_id, 'What is linear regression?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A classification method', 0, 0),
  (@q_id, 'Modeling the relationship between variables with a straight line', 1, 1),
  (@q_id, 'A type of neural network', 0, 2),
  (@q_id, 'A clustering algorithm', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz47_id, 'What is logistic regression?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A linear regression variant for regression', 0, 0),
  (@q_id, 'A classification algorithm estimating probability of class membership', 1, 1),
  (@q_id, 'A type of SVM', 0, 2),
  (@q_id, 'A neural network', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz47_id, 'What is a Support Vector Machine (SVM)?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of neural network', 0, 0),
  (@q_id, 'A classifier finding the optimal hyperplane separating classes', 1, 1),
  (@q_id, 'A clustering method', 0, 2),
  (@q_id, 'A regression model', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz47_id, 'What is Random Forest?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A single decision tree', 0, 0),
  (@q_id, 'An ensemble of decision trees to improve accuracy', 1, 1),
  (@q_id, 'A type of neural network', 0, 2),
  (@q_id, 'A clustering algorithm', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz47_id, 'What is gradient descent?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of tree', 0, 0),
  (@q_id, 'An optimization algorithm minimizing a loss function', 1, 1),
  (@q_id, 'A neural network architecture', 0, 2),
  (@q_id, 'A classification method', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz47_id, 'What is cross-validation?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Training on all data', 0, 0),
  (@q_id, 'A technique evaluating model performance on different data subsets', 1, 1),
  (@q_id, 'A type of regularization', 0, 2),
  (@q_id, 'A clustering method', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz47_id, 'What is feature engineering?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Selecting a model', 0, 0),
  (@q_id, 'Creating or transforming input variables to improve model performance', 1, 1),
  (@q_id, 'A type of algorithm', 0, 2),
  (@q_id, 'A regularization technique', 0, 3);

-- End Quiz 47: Machine Learning Algorithms

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Deep Learning and Neural Networks', 'Deep learning concepts and neural networks', 'AI/ML', 30, 75.00);
SET @quiz48_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz48_id, 'What is deep learning?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Machine learning with few layers', 0, 0),
  (@q_id, 'Machine learning using neural networks with many layers', 1, 1),
  (@q_id, 'A type of clustering', 0, 2),
  (@q_id, 'A regression method', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz48_id, 'What is a convolutional neural network (CNN)?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A text processing network', 0, 0),
  (@q_id, 'A neural network designed for processing grid-like data such as images', 1, 1),
  (@q_id, 'A type of RNN', 0, 2),
  (@q_id, 'A simple perceptron', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz48_id, 'What is a Recurrent Neural Network (RNN)?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A network for images', 0, 0),
  (@q_id, 'A neural network with loops for processing sequential data', 1, 1),
  (@q_id, 'A type of CNN', 0, 2),
  (@q_id, 'A feedforward network', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz48_id, 'What is an activation function?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A loss function', 0, 0),
  (@q_id, 'A function deciding whether a neuron should be activated', 1, 1),
  (@q_id, 'A learning rate', 0, 2),
  (@q_id, 'A type of layer', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz48_id, 'What is the ReLU activation function?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Returns -1 or 1', 0, 0),
  (@q_id, 'Returns max(0, x) — zero for negative inputs', 1, 1),
  (@q_id, 'Returns probability', 0, 2),
  (@q_id, 'Returns a squared value', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz48_id, 'What is backpropagation?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Forward data passing', 0, 0),
  (@q_id, 'The algorithm adjusting weights by propagating errors backward', 1, 1),
  (@q_id, 'A type of activation function', 0, 2),
  (@q_id, 'A regularization method', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz48_id, 'What is dropout in neural networks?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Removing neurons permanently', 0, 0),
  (@q_id, 'Randomly disabling neurons during training to prevent overfitting', 1, 1),
  (@q_id, 'A type of pooling', 0, 2),
  (@q_id, 'An activation function', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz48_id, 'What is a loss function?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'An activation function', 0, 0),
  (@q_id, 'A measure of how far model predictions are from actual values', 1, 1),
  (@q_id, 'A learning algorithm', 0, 2),
  (@q_id, 'A regularization method', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz48_id, 'What is transfer learning?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Training from scratch', 0, 0),
  (@q_id, 'Using a pre-trained model and adapting it to a new task', 1, 1),
  (@q_id, 'A type of clustering', 0, 2),
  (@q_id, 'A regularization technique', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz48_id, 'What is the purpose of batch normalization?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Reduce dataset size', 0, 0),
  (@q_id, 'Normalize inputs to each layer to speed up training and improve stability', 1, 1),
  (@q_id, 'Remove neurons', 0, 2),
  (@q_id, 'Change activation functions', 0, 3);

-- End Quiz 48: Deep Learning and Neural Networks

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Natural Language Processing', 'NLP concepts and techniques', 'AI/ML', 30, 75.00);
SET @quiz49_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz49_id, 'What does NLP stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Network Level Protocol', 0, 0),
  (@q_id, 'Natural Language Processing', 1, 1),
  (@q_id, 'Node Level Processing', 0, 2),
  (@q_id, 'Natural Logic Programming', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz49_id, 'What is tokenization in NLP?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Encrypting text', 0, 0),
  (@q_id, 'Splitting text into individual tokens like words or characters', 1, 1),
  (@q_id, 'Translating text', 0, 2),
  (@q_id, 'Summarizing text', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz49_id, 'What is sentiment analysis?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Translating text', 0, 0),
  (@q_id, 'Determining the emotional tone (positive/negative) of text', 1, 1),
  (@q_id, 'Summarizing text', 0, 2),
  (@q_id, 'Extracting names', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz49_id, 'What is named entity recognition (NER)?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Translating text', 0, 0),
  (@q_id, 'Identifying and classifying names, places, and organizations in text', 1, 1),
  (@q_id, 'Sentiment analysis', 0, 2),
  (@q_id, 'Text generation', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz49_id, 'What is a word embedding?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of tokenization', 0, 0),
  (@q_id, 'A representation of words as dense numerical vectors', 1, 1),
  (@q_id, 'A type of grammar', 0, 2),
  (@q_id, 'A translation model', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz49_id, 'What is the Transformer architecture?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of CNN', 0, 0),
  (@q_id, 'A neural network architecture using self-attention for sequential data', 1, 1),
  (@q_id, 'A type of RNN', 0, 2),
  (@q_id, 'A simple perceptron', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz49_id, 'What does BERT stand for?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Bidirectional Encoder Representations from Transformers', 1, 0),
  (@q_id, 'Basic Encoding and Recurrent Transformers', 0, 1),
  (@q_id, 'Bidirectional Error Reduction Technique', 0, 2),
  (@q_id, 'Base Encoder Representation Tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz49_id, 'What is text classification?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Generating text', 0, 0),
  (@q_id, 'Assigning predefined categories to text documents', 1, 1),
  (@q_id, 'Translating text', 0, 2),
  (@q_id, 'Named entity recognition', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz49_id, 'What is machine translation?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Human language teaching', 0, 0),
  (@q_id, 'Automatic translation from one language to another by a machine', 1, 1),
  (@q_id, 'Text summarization', 0, 2),
  (@q_id, 'Speech recognition', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz49_id, 'What is speech recognition?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Text-to-speech conversion', 0, 0),
  (@q_id, 'Converting spoken language into text', 1, 1),
  (@q_id, 'Sentiment analysis', 0, 2),
  (@q_id, 'Named entity recognition', 0, 3);

-- End Quiz 49: Natural Language Processing

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Computer Vision Basics', 'Introduction to computer vision', 'AI/ML', 30, 75.00);
SET @quiz50_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz50_id, 'What is computer vision?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of monitor', 0, 0),
  (@q_id, 'A field of AI enabling machines to interpret visual data', 1, 1),
  (@q_id, 'A programming language', 0, 2),
  (@q_id, 'A network protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz50_id, 'What is image classification?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Detecting objects in images', 0, 0),
  (@q_id, 'Assigning a label to an entire image', 1, 1),
  (@q_id, 'Segmenting images', 0, 2),
  (@q_id, 'Generating images', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz50_id, 'What is object detection?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Classifying an entire image', 0, 0),
  (@q_id, 'Identifying and locating multiple objects within an image', 1, 1),
  (@q_id, 'Image segmentation', 0, 2),
  (@q_id, 'Image generation', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz50_id, 'What is image segmentation?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Object detection', 0, 0),
  (@q_id, 'Partitioning an image into regions to identify object boundaries', 1, 1),
  (@q_id, 'Image classification', 0, 2),
  (@q_id, 'Feature extraction', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz50_id, 'What is OpenCV?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A cloud service', 0, 0),
  (@q_id, 'An open-source library for computer vision tasks', 1, 1),
  (@q_id, 'A type of neural network', 0, 2),
  (@q_id, 'A data format', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz50_id, 'What is a convolutional layer?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of pooling', 0, 0),
  (@q_id, 'A layer applying filters to detect features in images', 1, 1),
  (@q_id, 'A type of activation function', 0, 2),
  (@q_id, 'A loss function', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz50_id, 'What is data augmentation in CV?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Reducing dataset size', 0, 0),
  (@q_id, 'Artificially expanding training data by transforming images', 1, 1),
  (@q_id, 'Compressing images', 0, 2),
  (@q_id, 'Changing image format', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz50_id, 'What is face recognition?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Detecting faces in images', 0, 0),
  (@q_id, 'Identifying or verifying a person from their facial features', 1, 1),
  (@q_id, 'Image classification', 0, 2),
  (@q_id, 'Object detection', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz50_id, 'What is a GAN in AI?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Generative Adversarial Network — two networks competing to generate realistic data', 1, 0),
  (@q_id, 'General Adversarial Node', 0, 1),
  (@q_id, 'Graph Analysis Network', 0, 2),
  (@q_id, 'Gradient Adjustment Node', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz50_id, 'What is optical character recognition (OCR)?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Face detection', 0, 0),
  (@q_id, 'Converting images of text into machine-readable text', 1, 1),
  (@q_id, 'Object detection', 0, 2),
  (@q_id, 'Image classification', 0, 3);

-- End Quiz 50: Computer Vision Basics

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Computer Hardware Components', 'Understanding key computer hardware', 'Hardware', 30, 75.00);
SET @quiz51_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz51_id, 'What does CPU stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Central Processing Unit', 1, 0),
  (@q_id, 'Computer Processing Utility', 0, 1),
  (@q_id, 'Core Processing Unit', 0, 2),
  (@q_id, 'Central Program Unit', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz51_id, 'What is RAM?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Read-Only Memory', 0, 0),
  (@q_id, 'Random Access Memory used as temporary working memory', 1, 1),
  (@q_id, 'Remote Access Memory', 0, 2),
  (@q_id, 'Read After Memory', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz51_id, 'What is a GPU?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'General Processing Unit', 0, 0),
  (@q_id, 'Graphics Processing Unit designed for parallel computations', 1, 1),
  (@q_id, 'Ground Power Unit', 0, 2),
  (@q_id, 'Global Processing Utility', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz51_id, 'What is the motherboard?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of CPU', 0, 0),
  (@q_id, 'The main circuit board connecting all computer components', 1, 1),
  (@q_id, 'A type of storage', 0, 2),
  (@q_id, 'A networking card', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz51_id, 'What is the function of a power supply unit (PSU)?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Process data', 0, 0),
  (@q_id, 'Convert AC power from the wall to DC power for computer components', 1, 1),
  (@q_id, 'Store data', 0, 2),
  (@q_id, 'Display output', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz51_id, 'What is an SSD?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Standard Storage Disk', 0, 0),
  (@q_id, 'Solid State Drive — faster storage using flash memory', 1, 1),
  (@q_id, 'Static Storage Device', 0, 2),
  (@q_id, 'Serial Storage Drive', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz51_id, 'What does HDD stand for?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Hard Disk Drive — a magnetic storage device', 1, 0),
  (@q_id, 'High Definition Display', 0, 1),
  (@q_id, 'Hardware Development Device', 0, 2),
  (@q_id, 'High-speed Data Drive', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz51_id, 'What is a heat sink?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A power supply', 0, 0),
  (@q_id, 'A component that dissipates heat from the CPU', 1, 1),
  (@q_id, 'A type of RAM', 0, 2),
  (@q_id, 'A network card', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz51_id, 'What is NVMe?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A network protocol', 0, 0),
  (@q_id, 'A high-speed interface protocol for SSDs', 1, 1),
  (@q_id, 'A type of CPU', 0, 2),
  (@q_id, 'A RAM technology', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz51_id, 'What does BIOS stand for?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Basic Input Output System — firmware initializing hardware at startup', 1, 0),
  (@q_id, 'Binary Input/Output Software', 0, 1),
  (@q_id, 'Basic Integrated Operating System', 0, 2),
  (@q_id, 'Boot Input Output Software', 0, 3);

-- End Quiz 51: Computer Hardware Components

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Computer Architecture', 'Fundamentals of computer architecture', 'Hardware', 30, 75.00);
SET @quiz52_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz52_id, 'What is the Von Neumann architecture?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of OS', 0, 0),
  (@q_id, 'A model where CPU and memory are separate, sharing a bus', 1, 1),
  (@q_id, 'A type of GPU', 0, 2),
  (@q_id, 'A network design', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz52_id, 'What is the ALU?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Arithmetic Logic Unit — performs mathematical and logical operations', 1, 0),
  (@q_id, 'Advanced Lookup Unit', 0, 1),
  (@q_id, 'Array Logic Unit', 0, 2),
  (@q_id, 'Automated Learning Unit', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz52_id, 'What is the control unit in a CPU?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A memory chip', 0, 0),
  (@q_id, 'A component directing operations of the processor', 1, 1),
  (@q_id, 'A type of cache', 0, 2),
  (@q_id, 'A graphics processor', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz52_id, 'What is clock speed?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Size of CPU cache', 0, 0),
  (@q_id, 'The rate at which a CPU executes instructions, measured in Hz', 1, 1),
  (@q_id, 'Amount of RAM', 0, 2),
  (@q_id, 'Size of storage', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz52_id, 'What is cache memory?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of hard drive', 0, 0),
  (@q_id, 'Small, very fast memory storing frequently accessed CPU data', 1, 1),
  (@q_id, 'A type of RAM', 0, 2),
  (@q_id, 'A virtual memory', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz52_id, 'What is pipelining in CPU design?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of memory', 0, 0),
  (@q_id, 'Overlapping execution of multiple instructions to improve throughput', 1, 1),
  (@q_id, 'A type of cache', 0, 2),
  (@q_id, 'An OS feature', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz52_id, 'What does RISC stand for?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Rapid Instruction Set Computer', 0, 0),
  (@q_id, 'Reduced Instruction Set Computer — uses simple, uniform instructions', 1, 1),
  (@q_id, 'Remote Instruction Set Control', 0, 2),
  (@q_id, 'Real-time Instruction Set Computer', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz52_id, 'What does CISC stand for?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Complex Instruction Set Computer — instructions that do more work per command', 1, 0),
  (@q_id, 'Compact Instruction Set Control', 0, 1),
  (@q_id, 'Central Instruction Set Computer', 0, 2),
  (@q_id, 'Complete Instruction Set Computer', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz52_id, 'What is a register in CPU?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of RAM', 0, 0),
  (@q_id, 'Very fast, small storage inside the CPU for immediate data', 1, 1),
  (@q_id, 'A type of cache', 0, 2),
  (@q_id, 'A type of instruction', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz52_id, 'What is the memory hierarchy?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of CPU', 0, 0),
  (@q_id, 'A layered structure from fastest/smallest (registers) to slowest/largest (disk)', 1, 1),
  (@q_id, 'A type of OS', 0, 2),
  (@q_id, 'A database structure', 0, 3);

-- End Quiz 52: Computer Architecture

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Memory and Storage Technologies', 'Types of memory and storage in computers', 'Hardware', 30, 75.00);
SET @quiz53_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz53_id, 'What is DRAM?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Static RAM', 0, 0),
  (@q_id, 'Dynamic RAM — needs constant refreshing to hold data', 1, 1),
  (@q_id, 'Direct RAM', 0, 2),
  (@q_id, 'Dual RAM', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz53_id, 'What is SRAM?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Dynamic RAM', 0, 0),
  (@q_id, 'Static RAM — faster, holds data without refreshing, used in cache', 1, 1),
  (@q_id, 'Serial RAM', 0, 2),
  (@q_id, 'Synchronous RAM', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz53_id, 'What is flash memory?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of DRAM', 0, 0),
  (@q_id, 'Non-volatile memory storing data without power', 1, 1),
  (@q_id, 'A type of cache', 0, 2),
  (@q_id, 'Magnetic storage', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz53_id, 'What is EEPROM?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of RAM', 0, 0),
  (@q_id, 'Electrically Erasable Programmable ROM — can be reprogrammed electrically', 1, 1),
  (@q_id, 'A type of HDD', 0, 2),
  (@q_id, 'A CPU register', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz53_id, 'What is the difference between volatile and non-volatile memory?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Volatile is slower', 0, 0),
  (@q_id, 'Volatile loses data when power is off; non-volatile retains data', 1, 1),
  (@q_id, 'Non-volatile is always faster', 0, 2),
  (@q_id, 'Volatile is cheaper', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz53_id, 'What is DDR5 RAM?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Fifth generation Dynamic Double Data Rate RAM', 1, 0),
  (@q_id, 'A type of SSD', 0, 1),
  (@q_id, 'A CPU type', 0, 2),
  (@q_id, 'A network card', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz53_id, 'What is the purpose of ROM?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Temporary data storage', 0, 0),
  (@q_id, 'Permanent storage of firmware that persists when power is off', 1, 1),
  (@q_id, 'Cache storage', 0, 2),
  (@q_id, 'Virtual memory', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz53_id, 'What is an M.2 slot?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A memory slot for DRAM', 0, 0),
  (@q_id, 'A form factor slot for SSDs supporting NVMe or SATA', 1, 1),
  (@q_id, 'A GPU slot', 0, 2),
  (@q_id, 'A CPU socket', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz53_id, 'What is SATA?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A network protocol', 0, 0),
  (@q_id, 'Serial Advanced Technology Attachment — an interface connecting storage devices', 1, 1),
  (@q_id, 'A type of RAM', 0, 2),
  (@q_id, 'A CPU socket', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz53_id, 'What does \'storage capacity\' refer to?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'RAM speed', 0, 0),
  (@q_id, 'The amount of data a storage device can hold', 1, 1),
  (@q_id, 'CPU speed', 0, 2),
  (@q_id, 'Cache size', 0, 3);

-- End Quiz 53: Memory and Storage Technologies

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Input and Output Devices', 'Common input and output devices', 'Hardware', 30, 75.00);
SET @quiz54_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz54_id, 'Which of the following is an input device?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Monitor', 0, 0),
  (@q_id, 'Printer', 0, 1),
  (@q_id, 'Keyboard', 1, 2),
  (@q_id, 'Speaker', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz54_id, 'Which of the following is an output device?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Keyboard', 0, 0),
  (@q_id, 'Mouse', 0, 1),
  (@q_id, 'Microphone', 0, 2),
  (@q_id, 'Printer', 1, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz54_id, 'What is a touch screen?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'An input device only', 0, 0),
  (@q_id, 'An output device only', 0, 1),
  (@q_id, 'Both an input and output device', 1, 2),
  (@q_id, 'Neither', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz54_id, 'What does DPI stand for in context of a mouse?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Dots Per Interface', 0, 0),
  (@q_id, 'Dots Per Inch — measures mouse sensitivity', 1, 1),
  (@q_id, 'Data Per Input', 0, 2),
  (@q_id, 'Display Pixel Index', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz54_id, 'What type of device is a webcam?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Output only', 0, 0),
  (@q_id, 'Input only — captures video', 1, 1),
  (@q_id, 'Both input and output', 0, 2),
  (@q_id, 'Storage device', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz54_id, 'What is the function of a scanner?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Print documents', 0, 0),
  (@q_id, 'Convert physical documents to digital format', 1, 1),
  (@q_id, 'Display images', 0, 2),
  (@q_id, 'Store files', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz54_id, 'What does HDMI stand for?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'High Definition Multimedia Interface', 1, 0),
  (@q_id, 'High Data Media Input', 0, 1),
  (@q_id, 'Hard Drive Media Interface', 0, 2),
  (@q_id, 'High Definition Monitor Interface', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz54_id, 'What type of port does a USB flash drive use?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'HDMI', 0, 0),
  (@q_id, 'VGA', 0, 1),
  (@q_id, 'USB', 1, 2),
  (@q_id, 'DisplayPort', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz54_id, 'What is the function of a DAC in audio output?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Analog to Digital Converter', 0, 0),
  (@q_id, 'Digital to Analog Converter — converts digital audio to analog signal', 1, 1),
  (@q_id, 'A type of microphone', 0, 2),
  (@q_id, 'An audio compressor', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz54_id, 'What is a KVM switch?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A network switch', 0, 0),
  (@q_id, 'A device allowing one keyboard, video, and mouse to control multiple computers', 1, 1),
  (@q_id, 'A type of GPU', 0, 2),
  (@q_id, 'An audio device', 0, 3);

-- End Quiz 54: Input and Output Devices

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Computer Assembly and Maintenance', 'PC assembly and basic hardware maintenance', 'Hardware', 30, 75.00);
SET @quiz55_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz55_id, 'What is thermal paste used for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Lubricating fans', 0, 0),
  (@q_id, 'Improving heat transfer between CPU and heat sink', 1, 1),
  (@q_id, 'Cleaning circuit boards', 0, 2),
  (@q_id, 'Securing components', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz55_id, 'What does POST stand for?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Power On Self Test — hardware check performed at startup', 1, 0),
  (@q_id, 'Program On Start Transfer', 0, 1),
  (@q_id, 'Process Operating System Test', 0, 2),
  (@q_id, 'Power Output System Test', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz55_id, 'What should you do before handling computer components?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Put on gloves', 0, 0),
  (@q_id, 'Ground yourself to prevent electrostatic discharge', 1, 1),
  (@q_id, 'Wash your hands with water', 0, 2),
  (@q_id, 'Turn on the computer', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz55_id, 'What tool is most commonly used for PC assembly?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Hammer', 0, 0),
  (@q_id, 'Screwdriver (Phillips head)', 1, 1),
  (@q_id, 'Soldering iron', 0, 2),
  (@q_id, 'Wrench', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz55_id, 'What does the form factor of a motherboard determine?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'CPU speed', 0, 0),
  (@q_id, 'Physical size and layout compatible with cases and PSUs', 1, 1),
  (@q_id, 'RAM speed', 0, 2),
  (@q_id, 'GPU performance', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz55_id, 'What is the purpose of standoffs in a PC case?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Cooling', 0, 0),
  (@q_id, 'Elevating the motherboard from the case to prevent short circuits', 1, 1),
  (@q_id, 'Securing drives', 0, 2),
  (@q_id, 'Routing cables', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz55_id, 'What does RGB refer to in PC components?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Red Green Blue — lighting used in gaming setups', 1, 0),
  (@q_id, 'A type of RAM', 0, 1),
  (@q_id, 'A CPU socket', 0, 2),
  (@q_id, 'A network standard', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz55_id, 'What is cable management in a PC build?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Organizing cables for better airflow and aesthetics', 1, 0),
  (@q_id, 'Cutting cables', 0, 1),
  (@q_id, 'Installing drives', 0, 2),
  (@q_id, 'Grounding the PC', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz55_id, 'What does \'POST beep code\' indicate?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A successful boot', 0, 0),
  (@q_id, 'A hardware error identified during POST', 1, 1),
  (@q_id, 'The CPU model', 0, 2),
  (@q_id, 'RAM speed', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz55_id, 'What is the purpose of a PC case fan?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Providing RGB lighting', 0, 0),
  (@q_id, 'Moving air to cool internal components', 1, 1),
  (@q_id, 'Powering the CPU', 0, 2),
  (@q_id, 'Storing files', 0, 3);

-- End Quiz 55: Computer Assembly and Maintenance

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Information Systems', 'Concepts in information systems', 'Information Systems', 30, 75.00);
SET @quiz56_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz56_id, 'What is an Information System?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A programming language', 0, 0),
  (@q_id, 'A combination of people, technology, and data that processes information', 1, 1),
  (@q_id, 'A database only', 0, 2),
  (@q_id, 'A type of network', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz56_id, 'What does MIS stand for?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Modern Information Storage', 0, 0),
  (@q_id, 'Management Information System — supports management decision-making', 1, 1),
  (@q_id, 'Managed Internet Service', 0, 2),
  (@q_id, 'Multiple Information Systems', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz56_id, 'What is an ERP system?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Email Relay Protocol', 0, 0),
  (@q_id, 'Enterprise Resource Planning — integrates business processes', 1, 1),
  (@q_id, 'Error Reporting Protocol', 0, 2),
  (@q_id, 'External Resource Provider', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz56_id, 'What is a CRM system?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Computer Resource Management', 0, 0),
  (@q_id, 'Customer Relationship Management — manages customer interactions', 1, 1),
  (@q_id, 'Content Resource Model', 0, 2),
  (@q_id, 'Central Record Management', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz56_id, 'What is business intelligence (BI)?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of AI', 0, 0),
  (@q_id, 'Tools and strategies for analyzing business data to support decisions', 1, 1),
  (@q_id, 'A programming language', 0, 2),
  (@q_id, 'A networking tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz56_id, 'What is a data warehouse?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A physical storage room', 0, 0),
  (@q_id, 'A central repository of integrated data from multiple sources for analysis', 1, 1),
  (@q_id, 'A type of database server', 0, 2),
  (@q_id, 'A cloud service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz56_id, 'What is OLTP?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Online Transaction Processing — systems managing transactional databases', 1, 0),
  (@q_id, 'Offline Transaction Protocol', 0, 1),
  (@q_id, 'Online Testing Platform', 0, 2),
  (@q_id, 'Output Level Transaction Protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz56_id, 'What is OLAP?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Online Analytics Processing — systems for complex queries and business analysis', 1, 0),
  (@q_id, 'Offline Logic and Protocol', 0, 1),
  (@q_id, 'Output Level Analytics Platform', 0, 2),
  (@q_id, 'Online Loading and Processing', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz56_id, 'What is a decision support system (DSS)?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A database', 0, 0),
  (@q_id, 'A system that helps users make decisions by analyzing data', 1, 1),
  (@q_id, 'A type of ERP', 0, 2),
  (@q_id, 'A project management tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz56_id, 'What is a knowledge management system?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of AI', 0, 0),
  (@q_id, 'A system for capturing, storing, and sharing organizational knowledge', 1, 1),
  (@q_id, 'A type of ERP', 0, 2),
  (@q_id, 'A project tracker', 0, 3);

-- End Quiz 56: Information Systems

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Computer Ethics and Digital Citizenship', 'Ethical issues in computing', 'Ethics', 30, 75.00);
SET @quiz57_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz57_id, 'What is computer ethics?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Rules for coding', 0, 0),
  (@q_id, 'A set of moral principles governing the use of computers and technology', 1, 1),
  (@q_id, 'A type of cybersecurity', 0, 2),
  (@q_id, 'A programming standard', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz57_id, 'What is intellectual property (IP)?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Physical property owned by companies', 0, 0),
  (@q_id, 'Creations of the mind protected by copyright, patents, and trademarks', 1, 1),
  (@q_id, 'A type of network', 0, 2),
  (@q_id, 'An AI system', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz57_id, 'What is software piracy?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Creating software', 0, 0),
  (@q_id, 'Illegally copying or distributing copyrighted software', 1, 1),
  (@q_id, 'A type of virus', 0, 2),
  (@q_id, 'A hacking method', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz57_id, 'What is digital privacy?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Encrypting all data', 0, 0),
  (@q_id, 'The right to control personal information online', 1, 1),
  (@q_id, 'A type of firewall', 0, 2),
  (@q_id, 'An operating system feature', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz57_id, 'What is cyberbullying?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of malware', 0, 0),
  (@q_id, 'Using digital technology to harass or intimidate individuals', 1, 1),
  (@q_id, 'A type of phishing', 0, 2),
  (@q_id, 'A network attack', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz57_id, 'What is the right to be forgotten?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A memory technique', 0, 0),
  (@q_id, 'The right to request personal data be deleted from online platforms', 1, 1),
  (@q_id, 'A copyright law', 0, 2),
  (@q_id, 'A type of privacy setting', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz57_id, 'What does GDPR stand for?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'General Data Privacy Rules', 0, 0),
  (@q_id, 'General Data Protection Regulation — EU data privacy law', 1, 1),
  (@q_id, 'Global Digital Privacy Rights', 0, 2),
  (@q_id, 'General Deployment Protocol Regulations', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz57_id, 'What is net neutrality?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Internet speed equality', 0, 0),
  (@q_id, 'The principle that ISPs treat all internet traffic equally', 1, 1),
  (@q_id, 'A type of firewall', 0, 2),
  (@q_id, 'A payment system', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz57_id, 'What is digital divide?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of virus', 0, 0),
  (@q_id, 'The gap between those with and without access to digital technology', 1, 1),
  (@q_id, 'A network partition', 0, 2),
  (@q_id, 'A type of firewall', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz57_id, 'What is responsible disclosure in cybersecurity?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Publishing exploits immediately', 0, 0),
  (@q_id, 'Privately reporting vulnerabilities to vendors before public disclosure', 1, 1),
  (@q_id, 'Selling exploits', 0, 2),
  (@q_id, 'Ignoring vulnerabilities', 0, 3);

-- End Quiz 57: Computer Ethics and Digital Citizenship

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Node.js and Backend Development', 'Node.js and server-side development', 'Backend', 30, 75.00);
SET @quiz58_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz58_id, 'What is Node.js?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A frontend framework', 0, 0),
  (@q_id, 'A JavaScript runtime for executing JS on the server side', 1, 1),
  (@q_id, 'A database', 0, 2),
  (@q_id, 'A CSS framework', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz58_id, 'What is npm?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Node Package Manager — manages JavaScript packages', 1, 0),
  (@q_id, 'Network Protocol Manager', 0, 1),
  (@q_id, 'Node Program Module', 0, 2),
  (@q_id, 'Node Processing Module', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz58_id, 'What is Express.js?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A CSS framework', 0, 0),
  (@q_id, 'A minimal web application framework for Node.js', 1, 1),
  (@q_id, 'A database ORM', 0, 2),
  (@q_id, 'A frontend library', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz58_id, 'What is middleware in Express?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of database', 0, 0),
  (@q_id, 'Functions that process requests before reaching route handlers', 1, 1),
  (@q_id, 'A type of view', 0, 2),
  (@q_id, 'A CSS class', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz58_id, 'What does \'async/await\' do in Node.js?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Runs synchronous code faster', 0, 0),
  (@q_id, 'Handles asynchronous operations in a cleaner, synchronous-looking syntax', 1, 1),
  (@q_id, 'A type of loop', 0, 2),
  (@q_id, 'A module system', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz58_id, 'What is an event loop in Node.js?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of for loop', 0, 0),
  (@q_id, 'A mechanism handling non-blocking I/O operations asynchronously', 1, 1),
  (@q_id, 'A type of timer', 0, 2),
  (@q_id, 'A loop for DOM events', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz58_id, 'What is REST in backend development?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A sleep protocol', 0, 0),
  (@q_id, 'An architectural style for building scalable web services using HTTP', 1, 1),
  (@q_id, 'A database design', 0, 2),
  (@q_id, 'A type of framework', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz58_id, 'What is JWT?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'JavaScript Web Token — a way to securely transmit information as JSON', 0, 0),
  (@q_id, 'Java Web Technology', 0, 1),
  (@q_id, 'JSON Web Token — a compact way to transmit claims between parties', 1, 2),
  (@q_id, 'JavaScript Web Timer', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz58_id, 'What is a package.json file?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A configuration file', 0, 0),
  (@q_id, 'A manifest file for a Node.js project listing dependencies and scripts', 1, 1),
  (@q_id, 'A database file', 0, 2),
  (@q_id, 'A CSS file', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz58_id, 'What is the purpose of \'nodemon\'?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A database tool', 0, 0),
  (@q_id, 'Automatically restarting Node.js server when files change', 1, 1),
  (@q_id, 'A security module', 0, 2),
  (@q_id, 'A testing tool', 0, 3);

-- End Quiz 58: Node.js and Backend Development

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Linux Administration', 'Linux system administration commands and concepts', 'Linux', 30, 75.00);
SET @quiz59_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz59_id, 'Which command shows current directory in Linux?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'where', 0, 0),
  (@q_id, 'location', 0, 1),
  (@q_id, 'pwd', 1, 2),
  (@q_id, 'currentdir', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz59_id, 'What does \'sudo\' do?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Runs a command as current user', 0, 0),
  (@q_id, 'Runs a command with superuser (root) privileges', 1, 1),
  (@q_id, 'Shows disk usage', 0, 2),
  (@q_id, 'Lists directory', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz59_id, 'What does \'chmod 755\' give as permissions?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Read-only for all', 0, 0),
  (@q_id, 'Owner: rwx, Group: r-x, Others: r-x', 1, 1),
  (@q_id, 'Full access to all', 0, 2),
  (@q_id, 'No access to others', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz59_id, 'What is cron in Linux?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A text editor', 0, 0),
  (@q_id, 'A time-based job scheduler for running scripts automatically', 1, 1),
  (@q_id, 'A package manager', 0, 2),
  (@q_id, 'A file system', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz59_id, 'What command installs packages in Ubuntu?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'yum install', 0, 0),
  (@q_id, 'apt install', 1, 1),
  (@q_id, 'pip install', 0, 2),
  (@q_id, 'brew install', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz59_id, 'What does \'cat\' command do in Linux?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Lists files', 0, 0),
  (@q_id, 'Displays file contents', 1, 1),
  (@q_id, 'Copies files', 0, 2),
  (@q_id, 'Creates files', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz59_id, 'What is a shell script?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of database', 0, 0),
  (@q_id, 'A file containing a series of Linux commands to be executed', 1, 1),
  (@q_id, 'A type of filesystem', 0, 2),
  (@q_id, 'A system call', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz59_id, 'What does \'kill\' command do in Linux?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Deletes files', 0, 0),
  (@q_id, 'Terminates a running process', 1, 1),
  (@q_id, 'Renames files', 0, 2),
  (@q_id, 'Creates directories', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz59_id, 'What is the purpose of \'/etc/hosts\' file?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Stores user passwords', 0, 0),
  (@q_id, 'Maps hostnames to IP addresses locally', 1, 1),
  (@q_id, 'Stores cron jobs', 0, 2),
  (@q_id, 'Defines mount points', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz59_id, 'Which command shows network interfaces in Linux?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'netstat', 0, 0),
  (@q_id, 'ifconfig or ip addr', 1, 1),
  (@q_id, 'ping', 0, 2),
  (@q_id, 'traceroute', 0, 3);

-- End Quiz 59: Linux Administration

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Version Control with Git', 'Git version control concepts and commands', 'Git', 30, 75.00);
SET @quiz60_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz60_id, 'What is Git?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A programming language', 0, 0),
  (@q_id, 'A distributed version control system', 1, 1),
  (@q_id, 'A cloud service', 0, 2),
  (@q_id, 'A project management tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz60_id, 'What does \'git init\' do?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Clones a repository', 0, 0),
  (@q_id, 'Initializes a new Git repository', 1, 1),
  (@q_id, 'Commits changes', 0, 2),
  (@q_id, 'Creates a branch', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz60_id, 'What does \'git clone\' do?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Creates a new repository', 0, 0),
  (@q_id, 'Copies a remote repository to your local machine', 1, 1),
  (@q_id, 'Commits changes', 0, 2),
  (@q_id, 'Creates a branch', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz60_id, 'What does \'git add\' do?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Commits changes', 0, 0),
  (@q_id, 'Stages changes for the next commit', 1, 1),
  (@q_id, 'Creates a branch', 0, 2),
  (@q_id, 'Pushes to remote', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz60_id, 'What does \'git commit\' do?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Saves staged changes to the repository with a message', 1, 0),
  (@q_id, 'Pushes changes', 0, 1),
  (@q_id, 'Creates a branch', 0, 2),
  (@q_id, 'Reverts changes', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz60_id, 'What does \'git push\' do?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Downloads changes', 0, 0),
  (@q_id, 'Uploads local commits to the remote repository', 1, 1),
  (@q_id, 'Creates a branch', 0, 2),
  (@q_id, 'Merges branches', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz60_id, 'What does \'git pull\' do?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Uploads changes', 0, 0),
  (@q_id, 'Downloads and merges changes from the remote repository', 1, 1),
  (@q_id, 'Creates a branch', 0, 2),
  (@q_id, 'Reverts commits', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz60_id, 'What is a branch in Git?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of commit', 0, 0),
  (@q_id, 'A parallel version of the repository for isolated development', 1, 1),
  (@q_id, 'A remote server', 0, 2),
  (@q_id, 'A merge', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz60_id, 'What does \'git merge\' do?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Creates a branch', 0, 0),
  (@q_id, 'Combines two branches into one', 1, 1),
  (@q_id, 'Reverts changes', 0, 2),
  (@q_id, 'Deletes a branch', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz60_id, 'What does \'git status\' show?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'List of commits', 0, 0),
  (@q_id, 'Current state of the working directory and staging area', 1, 1),
  (@q_id, 'Remote branches', 0, 2),
  (@q_id, 'Ignored files', 0, 3);

-- End Quiz 60: Version Control with Git

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'IoT Fundamentals', 'Introduction to the Internet of Things', 'IoT', 30, 75.00);
SET @quiz61_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz61_id, 'What does IoT stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Internet of Technology', 0, 0),
  (@q_id, 'Internet of Things — connected physical devices exchanging data', 1, 1),
  (@q_id, 'Internal Operations Technology', 0, 2),
  (@q_id, 'Integrated Online Transfer', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz61_id, 'Which protocol is commonly used in IoT messaging?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'HTTP', 0, 0),
  (@q_id, 'MQTT — a lightweight messaging protocol for IoT devices', 1, 1),
  (@q_id, 'FTP', 0, 2),
  (@q_id, 'SMTP', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz61_id, 'What is a sensor in IoT?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of router', 0, 0),
  (@q_id, 'A device that detects physical data like temperature or motion', 1, 1),
  (@q_id, 'A network protocol', 0, 2),
  (@q_id, 'A cloud service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz61_id, 'What is an actuator in IoT?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A sensor', 0, 0),
  (@q_id, 'A device that performs an action based on commands received', 1, 1),
  (@q_id, 'A type of gateway', 0, 2),
  (@q_id, 'A protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz61_id, 'What is an IoT gateway?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A sensor', 0, 0),
  (@q_id, 'A device bridging IoT devices and the internet/cloud', 1, 1),
  (@q_id, 'A type of cloud', 0, 2),
  (@q_id, 'A protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz61_id, 'What is edge computing in IoT?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Cloud computing', 0, 0),
  (@q_id, 'Processing data near the source rather than sending all data to the cloud', 1, 1),
  (@q_id, 'A type of sensor', 0, 2),
  (@q_id, 'A network protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz61_id, 'What wireless technology do most smart home devices use?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Ethernet', 0, 0),
  (@q_id, 'WiFi and Bluetooth', 1, 1),
  (@q_id, 'Fiber optic', 0, 2),
  (@q_id, 'HDMI', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz61_id, 'What is a major security concern in IoT?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Power consumption', 0, 0),
  (@q_id, 'Many devices have weak security and limited update mechanisms', 1, 1),
  (@q_id, 'High cost', 0, 2),
  (@q_id, 'Large size', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz61_id, 'What protocol does Zigbee use?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'WiFi', 0, 0),
  (@q_id, 'A low-power, low-data-rate mesh networking protocol', 1, 1),
  (@q_id, 'Bluetooth', 0, 2),
  (@q_id, 'Ethernet', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz61_id, 'What is a digital twin in IoT?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A backup device', 0, 0),
  (@q_id, 'A virtual replica of a physical device or system', 1, 1),
  (@q_id, 'A type of sensor', 0, 2),
  (@q_id, 'A cloud database', 0, 3);

-- End Quiz 61: IoT Fundamentals

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Mobile Development Basics', 'Introduction to mobile app development', 'Mobile Development', 30, 75.00);
SET @quiz62_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz62_id, 'What language is primarily used for Android development?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Swift', 0, 0),
  (@q_id, 'Kotlin and Java', 1, 1),
  (@q_id, 'Python', 0, 2),
  (@q_id, 'PHP', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz62_id, 'What language is primarily used for iOS development?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Java', 0, 0),
  (@q_id, 'Swift and Objective-C', 1, 1),
  (@q_id, 'Kotlin', 0, 2),
  (@q_id, 'C++', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz62_id, 'What is React Native?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A backend framework', 0, 0),
  (@q_id, 'A framework for building native mobile apps using JavaScript', 1, 1),
  (@q_id, 'A CSS framework', 0, 2),
  (@q_id, 'A database', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz62_id, 'What is Flutter?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A JavaScript framework', 0, 0),
  (@q_id, 'Google\'s UI toolkit for building natively compiled apps from one codebase', 1, 1),
  (@q_id, 'A backend tool', 0, 2),
  (@q_id, 'A database', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz62_id, 'What is the App Store?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Android marketplace', 0, 0),
  (@q_id, 'Apple\'s digital marketplace for iOS apps', 1, 1),
  (@q_id, 'A cloud service', 0, 2),
  (@q_id, 'A type of database', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz62_id, 'What is an APK?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Apple Package', 0, 0),
  (@q_id, 'Android Package Kit — the installation format for Android apps', 1, 1),
  (@q_id, 'A programming language', 0, 2),
  (@q_id, 'A cloud file', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz62_id, 'What is responsive design in mobile?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Fixed-size layouts', 0, 0),
  (@q_id, 'Designing UI that adapts to different screen sizes', 1, 1),
  (@q_id, 'A type of animation', 0, 2),
  (@q_id, 'A network protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz62_id, 'What is push notification?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'An email notification', 0, 0),
  (@q_id, 'A message sent by an app to a user\'s device even when the app isn\'t open', 1, 1),
  (@q_id, 'A type of SMS', 0, 2),
  (@q_id, 'A pull request', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz62_id, 'What does API mean in mobile development?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'App Protocol Interface', 0, 0),
  (@q_id, 'Application Programming Interface — defines how apps communicate with services', 1, 1),
  (@q_id, 'Android Program Interface', 0, 2),
  (@q_id, 'Application Process Interaction', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz62_id, 'What is the purpose of a mobile SDK?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of database', 0, 0),
  (@q_id, 'A set of tools and libraries for building apps on a specific platform', 1, 1),
  (@q_id, 'A network protocol', 0, 2),
  (@q_id, 'A UI design tool', 0, 3);

-- End Quiz 62: Mobile Development Basics

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Web Security Basics', 'Security concepts specific to web applications', 'Cybersecurity', 30, 75.00);
SET @quiz63_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz63_id, 'What is HTTPS?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A fast version of HTTP', 0, 0),
  (@q_id, 'HTTP secured with SSL/TLS encryption', 1, 1),
  (@q_id, 'A type of database', 0, 2),
  (@q_id, 'A network protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz63_id, 'What is a session cookie?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A permanent cookie', 0, 0),
  (@q_id, 'A cookie storing session ID to identify a user\'s login session', 1, 1),
  (@q_id, 'A type of database', 0, 2),
  (@q_id, 'A JavaScript variable', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz63_id, 'What is CSRF?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Cross-Site Request Forgery — tricking users into submitting unwanted requests', 1, 0),
  (@q_id, 'Cross-Site Resource Fetching', 0, 1),
  (@q_id, 'Client-Side Request Forgery', 0, 2),
  (@q_id, 'Content Security Request Feature', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz63_id, 'What does Content Security Policy (CSP) do?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Speed up websites', 0, 0),
  (@q_id, 'Prevent XSS by controlling which resources a page can load', 1, 1),
  (@q_id, 'Encrypt cookies', 0, 2),
  (@q_id, 'Manage sessions', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz63_id, 'What is an SSL certificate?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of password', 0, 0),
  (@q_id, 'A digital certificate authenticating website identity and enabling HTTPS', 1, 1),
  (@q_id, 'A firewall rule', 0, 2),
  (@q_id, 'A type of cookie', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz63_id, 'What is input validation?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Checking server responses', 0, 0),
  (@q_id, 'Verifying user input meets expected format to prevent injection attacks', 1, 1),
  (@q_id, 'A type of cookie', 0, 2),
  (@q_id, 'A session management technique', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz63_id, 'What is OWASP?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A programming language', 0, 0),
  (@q_id, 'Open Web Application Security Project — publishes web security standards', 1, 1),
  (@q_id, 'A type of firewall', 0, 2),
  (@q_id, 'A web framework', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz63_id, 'What does \'HSTS\' do?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Slow connections', 0, 0),
  (@q_id, 'Force browsers to use HTTPS instead of HTTP', 1, 1),
  (@q_id, 'Block cookies', 0, 2),
  (@q_id, 'Manage sessions', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz63_id, 'What is clickjacking?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of virus', 0, 0),
  (@q_id, 'Tricking users into clicking something different from what they see', 1, 1),
  (@q_id, 'A type of SQL injection', 0, 2),
  (@q_id, 'A DDoS attack', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz63_id, 'What is parameterized query?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A slow query', 0, 0),
  (@q_id, 'A query with placeholders preventing SQL injection', 1, 1),
  (@q_id, 'A type of stored procedure', 0, 2),
  (@q_id, 'An optimized query', 0, 3);

-- End Quiz 63: Web Security Basics

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'API Design and Development', 'Principles of API design', 'Web Development', 30, 75.00);
SET @quiz64_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz64_id, 'What is an API?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of database', 0, 0),
  (@q_id, 'Application Programming Interface — a way for software to communicate', 1, 1),
  (@q_id, 'A type of server', 0, 2),
  (@q_id, 'A UI component', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz64_id, 'What is a RESTful API?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Any web API', 0, 0),
  (@q_id, 'An API following REST architectural constraints using HTTP methods', 1, 1),
  (@q_id, 'A type of database', 0, 2),
  (@q_id, 'A GraphQL API', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz64_id, 'What is GraphQL?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A graph database', 0, 0),
  (@q_id, 'A query language for APIs allowing clients to request specific data', 1, 1),
  (@q_id, 'A type of REST', 0, 2),
  (@q_id, 'A network protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz64_id, 'What is API versioning?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Changing API passwords', 0, 0),
  (@q_id, 'Managing multiple versions of an API to support backward compatibility', 1, 1),
  (@q_id, 'A type of API key', 0, 2),
  (@q_id, 'A rate limiting technique', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz64_id, 'What is rate limiting in APIs?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Slowing down servers', 0, 0),
  (@q_id, 'Controlling how many requests a client can make in a time period', 1, 1),
  (@q_id, 'A type of authentication', 0, 2),
  (@q_id, 'A caching strategy', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz64_id, 'What is an API key?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A database password', 0, 0),
  (@q_id, 'A unique identifier used to authenticate API requests', 1, 1),
  (@q_id, 'A type of cookie', 0, 2),
  (@q_id, 'A JWT token', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz64_id, 'What does SOAP stand for?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Simple Object Access Protocol', 1, 0),
  (@q_id, 'Simple Open API Protocol', 0, 1),
  (@q_id, 'Service Object Access Protocol', 0, 2),
  (@q_id, 'Standard Output Access Protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz64_id, 'What is webhook?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of API key', 0, 0),
  (@q_id, 'An HTTP callback triggered by a specific event to notify other services', 1, 1),
  (@q_id, 'A type of REST endpoint', 0, 2),
  (@q_id, 'A database trigger', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz64_id, 'What is API documentation?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of API key', 0, 0),
  (@q_id, 'Information describing how to use an API\'s endpoints and parameters', 1, 1),
  (@q_id, 'A type of server', 0, 2),
  (@q_id, 'A database schema', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz64_id, 'What is idempotency in REST?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Speed of API', 0, 0),
  (@q_id, 'A property where making the same request multiple times has the same effect', 1, 1),
  (@q_id, 'A type of security', 0, 2),
  (@q_id, 'A versioning strategy', 0, 3);

-- End Quiz 64: API Design and Development

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Blockchain Technology', 'Introduction to blockchain fundamentals', 'Emerging Technology', 30, 75.00);
SET @quiz65_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz65_id, 'What is a blockchain?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of database', 0, 0),
  (@q_id, 'A distributed, immutable ledger recording transactions across many nodes', 1, 1),
  (@q_id, 'A type of cloud', 0, 2),
  (@q_id, 'A networking protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz65_id, 'What is a block in blockchain?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of server', 0, 0),
  (@q_id, 'A record containing a set of transactions in the blockchain', 1, 1),
  (@q_id, 'A type of hash', 0, 2),
  (@q_id, 'A network node', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz65_id, 'What makes blockchain immutable?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Encryption', 0, 0),
  (@q_id, 'Each block contains the hash of the previous block, making alteration detectable', 1, 1),
  (@q_id, 'Fast processing', 0, 2),
  (@q_id, 'Centralized control', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz65_id, 'What is a consensus mechanism?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A voting system', 0, 0),
  (@q_id, 'A method ensuring all nodes agree on the state of the blockchain', 1, 1),
  (@q_id, 'A type of hash', 0, 2),
  (@q_id, 'An encryption algorithm', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz65_id, 'What is Proof of Work (PoW)?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A consensus mechanism requiring computational effort to add blocks', 1, 0),
  (@q_id, 'A type of hash', 0, 1),
  (@q_id, 'A smart contract', 0, 2),
  (@q_id, 'A type of wallet', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz65_id, 'What is a smart contract?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A legal document', 0, 0),
  (@q_id, 'Self-executing code on the blockchain triggered by conditions', 1, 1),
  (@q_id, 'A type of wallet', 0, 2),
  (@q_id, 'A consensus mechanism', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz65_id, 'What is cryptocurrency?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A physical coin', 0, 0),
  (@q_id, 'A digital currency using cryptography secured by blockchain', 1, 1),
  (@q_id, 'A type of credit card', 0, 2),
  (@q_id, 'A database', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz65_id, 'What is a wallet in blockchain?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A physical storage', 0, 0),
  (@q_id, 'Software storing private and public keys for managing crypto assets', 1, 1),
  (@q_id, 'A type of node', 0, 2),
  (@q_id, 'A consensus mechanism', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz65_id, 'What is Ethereum?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A Bitcoin clone', 0, 0),
  (@q_id, 'A blockchain platform supporting smart contracts and decentralized apps', 1, 1),
  (@q_id, 'A type of wallet', 0, 2),
  (@q_id, 'A consensus mechanism', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz65_id, 'What is DeFi?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Decentralized Finance — financial services using smart contracts without intermediaries', 1, 0),
  (@q_id, 'A type of cryptocurrency', 0, 1),
  (@q_id, 'Default Finance', 0, 2),
  (@q_id, 'Distributed Fiat currency', 0, 3);

-- End Quiz 65: Blockchain Technology

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Cloud Security', 'Security in cloud computing environments', 'Cybersecurity', 30, 75.00);
SET @quiz66_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz66_id, 'What is the shared responsibility model in cloud?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Provider handles all security', 0, 0),
  (@q_id, 'Security responsibilities are split between provider and customer', 1, 1),
  (@q_id, 'Customer handles all security', 0, 2),
  (@q_id, 'Third party handles security', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz66_id, 'What is data encryption at rest?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Encrypting data in transit', 0, 0),
  (@q_id, 'Encrypting stored data when it\'s not being transferred', 1, 1),
  (@q_id, 'Hashing passwords', 0, 2),
  (@q_id, 'Firewall protection', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz66_id, 'What is data encryption in transit?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Encrypting stored data', 0, 0),
  (@q_id, 'Encrypting data while it is being transferred over a network', 1, 1),
  (@q_id, 'A type of firewall', 0, 2),
  (@q_id, 'Hashing data', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz66_id, 'What is IAM in cloud security?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Internet Access Management', 0, 0),
  (@q_id, 'Identity and Access Management — controlling who can access cloud resources', 1, 1),
  (@q_id, 'Internal API Management', 0, 2),
  (@q_id, 'Integrated Authentication Module', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz66_id, 'What is a cloud security posture?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Server location', 0, 0),
  (@q_id, 'The overall state of security controls and practices in a cloud environment', 1, 1),
  (@q_id, 'A type of firewall', 0, 2),
  (@q_id, 'A cloud storage type', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz66_id, 'What is multi-factor authentication (MFA)?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Using two passwords', 0, 0),
  (@q_id, 'Requiring multiple verification methods to access an account', 1, 1),
  (@q_id, 'A type of encryption', 0, 2),
  (@q_id, 'A firewall rule', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz66_id, 'What is cloud compliance?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Meeting speed requirements', 0, 0),
  (@q_id, 'Adhering to regulatory requirements and standards in cloud operations', 1, 1),
  (@q_id, 'A cost management strategy', 0, 2),
  (@q_id, 'A performance metric', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz66_id, 'What is a CASB?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Cloud Access Security Broker — mediating security between users and cloud services', 1, 0),
  (@q_id, 'Cloud Application Security Backup', 0, 1),
  (@q_id, 'Central Access Service Bus', 0, 2),
  (@q_id, 'Cloud API Security Bridge', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz66_id, 'What is cloud monitoring?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Watching clouds', 0, 0),
  (@q_id, 'Continuously tracking cloud resources, performance, and security events', 1, 1),
  (@q_id, 'A type of firewall', 0, 2),
  (@q_id, 'A storage service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz66_id, 'What is privilege escalation?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Giving users more permissions intentionally', 0, 0),
  (@q_id, 'An attacker gaining higher privileges than originally assigned', 1, 1),
  (@q_id, 'A type of firewall rule', 0, 2),
  (@q_id, 'A cloud feature', 0, 3);

-- End Quiz 66: Cloud Security

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Data Analytics and Visualization', 'Data analytics concepts and visualization', 'Data Analytics', 30, 75.00);
SET @quiz67_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz67_id, 'What is data analytics?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Creating databases', 0, 0),
  (@q_id, 'The process of examining data sets to draw conclusions and insights', 1, 1),
  (@q_id, 'A programming language', 0, 2),
  (@q_id, 'A type of storage', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz67_id, 'What is descriptive analytics?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Predicting future events', 0, 0),
  (@q_id, 'Analyzing historical data to understand what has happened', 1, 1),
  (@q_id, 'Prescribing actions', 0, 2),
  (@q_id, 'Diagnosing problems', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz67_id, 'What is predictive analytics?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Analyzing past data only', 0, 0),
  (@q_id, 'Using historical data and models to forecast future outcomes', 1, 1),
  (@q_id, 'Prescribing actions', 0, 2),
  (@q_id, 'Describing current state', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz67_id, 'What is prescriptive analytics?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Describing data', 0, 0),
  (@q_id, 'Recommending actions based on analysis to optimize outcomes', 1, 1),
  (@q_id, 'Predicting future', 0, 2),
  (@q_id, 'Describing past', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz67_id, 'What is a KPI?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Key Performance Indicator — a measurable value tracking performance', 1, 0),
  (@q_id, 'Key Process Integration', 0, 1),
  (@q_id, 'Key Program Input', 0, 2),
  (@q_id, 'Key Protocol Interface', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz67_id, 'What is data visualization?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Storing data', 0, 0),
  (@q_id, 'Representing data graphically to communicate insights clearly', 1, 1),
  (@q_id, 'Analyzing data statistically', 0, 2),
  (@q_id, 'Cleaning data', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz67_id, 'What tool is commonly used for data visualization?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Notepad', 0, 0),
  (@q_id, 'Tableau, Power BI, and Python libraries like matplotlib', 1, 1),
  (@q_id, 'Microsoft Word', 0, 2),
  (@q_id, 'Database clients', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz67_id, 'What is ETL?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Email Transfer Language', 0, 0),
  (@q_id, 'Extract, Transform, Load — a process moving data from sources to a warehouse', 1, 1),
  (@q_id, 'Encryption, Transfer, Loop', 0, 2),
  (@q_id, 'Event Transfer Logic', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz67_id, 'What is data cleaning?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Deleting databases', 0, 0),
  (@q_id, 'Removing errors, duplicates, and inconsistencies from data', 1, 1),
  (@q_id, 'Sorting data', 0, 2),
  (@q_id, 'Encrypting data', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz67_id, 'What is a dashboard in analytics?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A car instrument panel', 0, 0),
  (@q_id, 'A visual display of key metrics and data in one view', 1, 1),
  (@q_id, 'A type of database', 0, 2),
  (@q_id, 'A reporting template', 0, 3);

-- End Quiz 67: Data Analytics and Visualization

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Software Project Management', 'Managing software development projects', 'Software Engineering', 30, 75.00);
SET @quiz68_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz68_id, 'What is a project scope?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The project budget', 0, 0),
  (@q_id, 'The boundaries and deliverables of a project', 1, 1),
  (@q_id, 'The team roster', 0, 2),
  (@q_id, 'The timeline only', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz68_id, 'What is a Gantt chart?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of code diagram', 0, 0),
  (@q_id, 'A bar chart showing project schedule and task timelines', 1, 1),
  (@q_id, 'A UML diagram', 0, 2),
  (@q_id, 'A class hierarchy', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz68_id, 'What is risk management in software projects?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Ignoring risks', 0, 0),
  (@q_id, 'Identifying, analyzing, and responding to project risks', 1, 1),
  (@q_id, 'Writing code', 0, 2),
  (@q_id, 'Testing software', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz68_id, 'What is a milestone in project management?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A budget item', 0, 0),
  (@q_id, 'A significant event or achievement in a project timeline', 1, 1),
  (@q_id, 'A type of task', 0, 2),
  (@q_id, 'A team meeting', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz68_id, 'What is the critical path in project management?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The easiest tasks', 0, 0),
  (@q_id, 'The longest sequence of tasks determining the minimum project duration', 1, 1),
  (@q_id, 'The most expensive tasks', 0, 2),
  (@q_id, 'The first tasks done', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz68_id, 'What is a stakeholder?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A database record', 0, 0),
  (@q_id, 'Any person or group with an interest in the project outcome', 1, 1),
  (@q_id, 'A type of server', 0, 2),
  (@q_id, 'A team member only', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz68_id, 'What is scope creep?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Reducing project scope', 0, 0),
  (@q_id, 'Uncontrolled expansion of project requirements beyond initial plans', 1, 1),
  (@q_id, 'A type of bug', 0, 2),
  (@q_id, 'A deployment issue', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz68_id, 'What is a WBS?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Web-Based Software', 0, 0),
  (@q_id, 'Work Breakdown Structure — decomposing a project into smaller tasks', 1, 1),
  (@q_id, 'Web Browser Software', 0, 2),
  (@q_id, 'Weekly Backup Schedule', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz68_id, 'What is Earned Value Management (EVM)?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A payment method', 0, 0),
  (@q_id, 'A technique measuring project performance against the plan', 1, 1),
  (@q_id, 'A type of budget', 0, 2),
  (@q_id, 'A sprint metric', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz68_id, 'What is a sprint backlog?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The full product backlog', 0, 0),
  (@q_id, 'The list of tasks selected for the current sprint', 1, 1),
  (@q_id, 'A list of bugs', 0, 2),
  (@q_id, 'A team meeting agenda', 0, 3);

-- End Quiz 68: Software Project Management

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Cybersecurity Tools and Practices', 'Common cybersecurity tools and best practices', 'Cybersecurity', 30, 75.00);
SET @quiz69_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz69_id, 'What is Wireshark?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A firewall', 0, 0),
  (@q_id, 'A network protocol analyzer capturing and analyzing network traffic', 1, 1),
  (@q_id, 'A type of VPN', 0, 2),
  (@q_id, 'A password manager', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz69_id, 'What is a password manager?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of firewall', 0, 0),
  (@q_id, 'A tool that securely stores and manages passwords', 1, 1),
  (@q_id, 'A virus scanner', 0, 2),
  (@q_id, 'A network monitor', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz69_id, 'What is antivirus software?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of firewall', 0, 0),
  (@q_id, 'Software that detects and removes malware from a system', 1, 1),
  (@q_id, 'A network scanner', 0, 2),
  (@q_id, 'A VPN tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz69_id, 'What is patch management?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Writing new software', 0, 0),
  (@q_id, 'The process of applying updates to fix vulnerabilities in software', 1, 1),
  (@q_id, 'A type of backup', 0, 2),
  (@q_id, 'A firewall configuration', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz69_id, 'What is security auditing?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of penetration test', 0, 0),
  (@q_id, 'Reviewing and evaluating security policies and controls systematically', 1, 1),
  (@q_id, 'A type of firewall', 0, 2),
  (@q_id, 'A backup strategy', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz69_id, 'What is a SIEM system?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Security Information and Event Management — aggregating and analyzing security events', 1, 0),
  (@q_id, 'Service Integration Enterprise Module', 0, 1),
  (@q_id, 'Simple Intrusion Event Management', 0, 2),
  (@q_id, 'Secure Internal Event Monitor', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz69_id, 'What is endpoint security?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Server security only', 0, 0),
  (@q_id, 'Protecting devices like laptops and phones that connect to a network', 1, 1),
  (@q_id, 'Firewall configuration', 0, 2),
  (@q_id, 'VPN setup', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz69_id, 'What is data loss prevention (DLP)?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Deleting sensitive data', 0, 0),
  (@q_id, 'Tools preventing unauthorized sharing or exfiltration of sensitive data', 1, 1),
  (@q_id, 'A backup system', 0, 2),
  (@q_id, 'A type of firewall', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz69_id, 'What is threat intelligence?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Guessing about threats', 0, 0),
  (@q_id, 'Information about current and potential cybersecurity threats and attackers', 1, 1),
  (@q_id, 'A type of antivirus', 0, 2),
  (@q_id, 'A firewall rule', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz69_id, 'What is a security baseline?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A minimum security configuration all systems must meet', 1, 0),
  (@q_id, 'The most secure possible setup', 0, 1),
  (@q_id, 'A list of vulnerabilities', 0, 2),
  (@q_id, 'A firewall rule', 0, 3);

-- End Quiz 69: Cybersecurity Tools and Practices

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'DevOps Practices', 'DevOps principles and practices', 'Software Engineering', 30, 75.00);
SET @quiz70_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz70_id, 'What is DevOps?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A programming language', 0, 0),
  (@q_id, 'A culture and practice combining development and operations for faster delivery', 1, 1),
  (@q_id, 'A type of database', 0, 2),
  (@q_id, 'A cloud provider', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz70_id, 'What does CI/CD stand for?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Continuous Integration/Continuous Delivery or Deployment', 1, 0),
  (@q_id, 'Computer Interface/Computer Deployment', 0, 1),
  (@q_id, 'Centralized Integration/Centralized Deployment', 0, 2),
  (@q_id, 'Code Integration/Code Deployment', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz70_id, 'What is Infrastructure as Code (IaC)?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Physical server management', 0, 0),
  (@q_id, 'Managing and provisioning infrastructure through code and automation', 1, 1),
  (@q_id, 'A type of database', 0, 2),
  (@q_id, 'A monitoring tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz70_id, 'What is a pipeline in DevOps?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A physical pipe', 0, 0),
  (@q_id, 'An automated sequence of steps from code commit to deployment', 1, 1),
  (@q_id, 'A type of database', 0, 2),
  (@q_id, 'A testing tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz70_id, 'What tool is popular for CI/CD pipelines?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Microsoft Word', 0, 0),
  (@q_id, 'Jenkins, GitHub Actions, and GitLab CI', 1, 1),
  (@q_id, 'Microsoft Excel', 0, 2),
  (@q_id, 'Notepad++', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz70_id, 'What is monitoring in DevOps?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Watching developers', 0, 0),
  (@q_id, 'Tracking application and infrastructure performance in real time', 1, 1),
  (@q_id, 'A type of testing', 0, 2),
  (@q_id, 'A deployment strategy', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz70_id, 'What is a rollback in DevOps?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Advancing to next version', 0, 0),
  (@q_id, 'Reverting to a previous version after a failed deployment', 1, 1),
  (@q_id, 'A type of test', 0, 2),
  (@q_id, 'A build step', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz70_id, 'What is blue-green deployment?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A color scheme', 0, 0),
  (@q_id, 'Running two identical production environments to enable zero-downtime deployments', 1, 1),
  (@q_id, 'A type of test', 0, 2),
  (@q_id, 'A monitoring strategy', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz70_id, 'What is Terraform?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A game', 0, 0),
  (@q_id, 'An IaC tool for building and managing cloud infrastructure', 1, 1),
  (@q_id, 'A CI/CD tool', 0, 2),
  (@q_id, 'A monitoring tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz70_id, 'What is a container registry?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of cloud', 0, 0),
  (@q_id, 'A repository for storing and distributing container images', 1, 1),
  (@q_id, 'A monitoring service', 0, 2),
  (@q_id, 'A CI/CD tool', 0, 3);

-- End Quiz 70: DevOps Practices

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Python for Data Science', 'Using Python for data science tasks', 'Python', 30, 75.00);
SET @quiz71_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz71_id, 'Which Python library is used for numerical computations?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'pandas', 0, 0),
  (@q_id, 'numpy', 1, 1),
  (@q_id, 'matplotlib', 0, 2),
  (@q_id, 'sklearn', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz71_id, 'Which library is used for data manipulation in Python?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'numpy', 0, 0),
  (@q_id, 'matplotlib', 0, 1),
  (@q_id, 'pandas', 1, 2),
  (@q_id, 'tensorflow', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz71_id, 'What is a DataFrame in pandas?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of function', 0, 0),
  (@q_id, 'A 2D labeled data structure like a table', 1, 1),
  (@q_id, 'A type of array', 0, 2),
  (@q_id, 'A visualization', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz71_id, 'Which library is used for machine learning in Python?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'pandas', 0, 0),
  (@q_id, 'numpy', 0, 1),
  (@q_id, 'scikit-learn', 1, 2),
  (@q_id, 'matplotlib', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz71_id, 'What does \'import numpy as np\' do?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Imports pandas', 0, 0),
  (@q_id, 'Imports the numpy library and gives it the alias np', 1, 1),
  (@q_id, 'Creates a variable', 0, 2),
  (@q_id, 'Defines a function', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz71_id, 'What method reads a CSV file in pandas?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'pd.read_excel()', 0, 0),
  (@q_id, 'pd.load_csv()', 0, 1),
  (@q_id, 'pd.read_csv()', 1, 2),
  (@q_id, 'pd.import_csv()', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz71_id, 'What is matplotlib used for?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Data manipulation', 0, 0),
  (@q_id, 'Creating visualizations and plots', 1, 1),
  (@q_id, 'Machine learning', 0, 2),
  (@q_id, 'Database queries', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz71_id, 'What does \'df.head()\' do?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Shows all rows', 0, 0),
  (@q_id, 'Shows the last 5 rows', 0, 1),
  (@q_id, 'Shows the first 5 rows of the DataFrame', 1, 2),
  (@q_id, 'Deletes first rows', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz71_id, 'What is a Series in pandas?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A 2D structure', 0, 0),
  (@q_id, 'A 1D labeled array-like object', 1, 1),
  (@q_id, 'A matrix', 0, 2),
  (@q_id, 'A dictionary', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz71_id, 'Which library provides deep learning tools in Python?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'pandas', 0, 0),
  (@q_id, 'numpy', 0, 1),
  (@q_id, 'tensorflow', 1, 2),
  (@q_id, 'matplotlib', 0, 3);

-- End Quiz 71: Python for Data Science

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Web Development Frameworks', 'Popular web development frameworks', 'Web Development', 30, 75.00);
SET @quiz72_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz72_id, 'What is Django?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A JavaScript framework', 0, 0),
  (@q_id, 'A high-level Python web framework', 1, 1),
  (@q_id, 'A CSS framework', 0, 2),
  (@q_id, 'A database', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz72_id, 'What is Laravel?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A Python framework', 0, 0),
  (@q_id, 'A PHP web framework following MVC pattern', 1, 1),
  (@q_id, 'A JavaScript library', 0, 2),
  (@q_id, 'A database', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz72_id, 'What is Vue.js?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A backend framework', 0, 0),
  (@q_id, 'A progressive JavaScript framework for building user interfaces', 1, 1),
  (@q_id, 'A CSS framework', 0, 2),
  (@q_id, 'A database ORM', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz72_id, 'What is Angular?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A CSS framework', 0, 0),
  (@q_id, 'A TypeScript-based web application framework by Google', 1, 1),
  (@q_id, 'A backend framework', 0, 2),
  (@q_id, 'A database', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz72_id, 'What is Next.js?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A CSS framework', 0, 0),
  (@q_id, 'A React framework for server-side rendering and static site generation', 1, 1),
  (@q_id, 'A backend database', 0, 2),
  (@q_id, 'A CSS library', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz72_id, 'What is Spring Boot?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A JavaScript framework', 0, 0),
  (@q_id, 'A Java framework for building standalone production-grade applications', 1, 1),
  (@q_id, 'A CSS library', 0, 2),
  (@q_id, 'A database ORM', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz72_id, 'What is Flask?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A JavaScript framework', 0, 0),
  (@q_id, 'A lightweight Python web microframework', 1, 1),
  (@q_id, 'A CSS library', 0, 2),
  (@q_id, 'A database', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz72_id, 'What is Tailwind CSS?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A JavaScript library', 0, 0),
  (@q_id, 'A utility-first CSS framework for rapid UI development', 1, 1),
  (@q_id, 'A backend framework', 0, 2),
  (@q_id, 'A database tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz72_id, 'What is ORM in web development?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Object Routing Module', 0, 0),
  (@q_id, 'Object Relational Mapper — maps database tables to code objects', 1, 1),
  (@q_id, 'Online Request Manager', 0, 2),
  (@q_id, 'Output Rendering Module', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz72_id, 'What does SSR stand for?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Static Site Rendering', 0, 0),
  (@q_id, 'Server-Side Rendering — generating HTML on the server', 1, 1),
  (@q_id, 'Simple State Routing', 0, 2),
  (@q_id, 'Single Source Routing', 0, 3);

-- End Quiz 72: Web Development Frameworks

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Computer Networks Advanced', 'Advanced networking concepts', 'Networking', 30, 75.00);
SET @quiz73_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz73_id, 'What is BGP?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Border Gateway Protocol — the routing protocol of the internet', 1, 0),
  (@q_id, 'Basic Gateway Protocol', 0, 1),
  (@q_id, 'Bandwidth Gateway Protocol', 0, 2),
  (@q_id, 'Bridged Group Protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz73_id, 'What is MPLS?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Multi-Protocol Label Switching — a routing technique using labels', 1, 0),
  (@q_id, 'Multiple Protocol Link Service', 0, 1),
  (@q_id, 'Maximum Packet Length System', 0, 2),
  (@q_id, 'Main Protocol Layer Switch', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz73_id, 'What is Quality of Service (QoS)?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Speed of a network', 0, 0),
  (@q_id, 'Mechanisms prioritizing network traffic for performance guarantees', 1, 1),
  (@q_id, 'A type of firewall', 0, 2),
  (@q_id, 'A routing protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz73_id, 'What is a VLAN trunk?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of VLAN', 0, 0),
  (@q_id, 'A link carrying traffic for multiple VLANs between switches', 1, 1),
  (@q_id, 'A type of router', 0, 2),
  (@q_id, 'A network cable', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz73_id, 'What is STP (Spanning Tree Protocol)?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of VPN', 0, 0),
  (@q_id, 'A protocol preventing network loops in Ethernet networks', 1, 1),
  (@q_id, 'A routing algorithm', 0, 2),
  (@q_id, 'A security protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz73_id, 'What is link aggregation?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Splitting a connection', 0, 0),
  (@q_id, 'Combining multiple network links into one logical link for bandwidth', 1, 1),
  (@q_id, 'A type of VLAN', 0, 2),
  (@q_id, 'A routing protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz73_id, 'What is network convergence?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of routing', 0, 0),
  (@q_id, 'The time it takes for all routers to agree on the network topology', 1, 1),
  (@q_id, 'A type of firewall', 0, 2),
  (@q_id, 'A switching protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz73_id, 'What is an anycast address?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A unicast address', 0, 0),
  (@q_id, 'An address assigned to multiple nodes, routed to nearest one', 1, 1),
  (@q_id, 'A multicast address', 0, 2),
  (@q_id, 'A broadcast address', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz73_id, 'What is NAT64?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of IPv4', 0, 0),
  (@q_id, 'A transition mechanism translating IPv6 addresses to IPv4', 1, 1),
  (@q_id, 'A routing protocol', 0, 2),
  (@q_id, 'A type of firewall', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz73_id, 'What is SD-WAN?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Software Defined WAN — managing WAN connections programmatically', 1, 0),
  (@q_id, 'Standard Definition WAN', 0, 1),
  (@q_id, 'Secure Data WAN', 0, 2),
  (@q_id, 'Static Domain WAN', 0, 3);

-- End Quiz 73: Computer Networks Advanced

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Quantum Computing Introduction', 'Basic concepts of quantum computing', 'Emerging Technology', 30, 75.00);
SET @quiz74_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz74_id, 'What is quantum computing?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Faster classical computing', 0, 0),
  (@q_id, 'Computing using quantum mechanics principles like superposition and entanglement', 1, 1),
  (@q_id, 'A type of GPU', 0, 2),
  (@q_id, 'A cloud service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz74_id, 'What is a qubit?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A classical bit', 0, 0),
  (@q_id, 'The basic unit of quantum information, existing in superposition', 1, 1),
  (@q_id, 'A quantum byte', 0, 2),
  (@q_id, 'A quantum gate', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz74_id, 'What is superposition in quantum computing?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of error', 0, 0),
  (@q_id, 'A qubit existing in multiple states simultaneously until measured', 1, 1),
  (@q_id, 'A type of gate', 0, 2),
  (@q_id, 'A quantum circuit', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz74_id, 'What is quantum entanglement?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Random noise', 0, 0),
  (@q_id, 'When qubits are correlated so the state of one affects another instantly', 1, 1),
  (@q_id, 'A quantum error', 0, 2),
  (@q_id, 'A type of gate', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz74_id, 'What is a quantum gate?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A quantum firewall', 0, 0),
  (@q_id, 'An operation performed on qubits, analogous to classical logic gates', 1, 1),
  (@q_id, 'A type of qubit', 0, 2),
  (@q_id, 'A quantum circuit', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz74_id, 'What advantage does quantum computing offer over classical?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'It\'s cheaper', 0, 0),
  (@q_id, 'It can solve certain complex problems exponentially faster', 1, 1),
  (@q_id, 'It uses no electricity', 0, 2),
  (@q_id, 'It never makes errors', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz74_id, 'What is quantum supremacy?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A quantum computer beating humans', 0, 0),
  (@q_id, 'A quantum computer performing a task no classical computer can in feasible time', 1, 1),
  (@q_id, 'A quantum error', 0, 2),
  (@q_id, 'A type of qubit', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz74_id, 'What company developed the quantum computer \'Sycamore\'?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'IBM', 0, 0),
  (@q_id, 'Microsoft', 0, 1),
  (@q_id, 'Google', 1, 2),
  (@q_id, 'Intel', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz74_id, 'What is Shor\'s algorithm used for?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Sorting data', 0, 0),
  (@q_id, 'Factoring large integers efficiently — threatening RSA encryption', 1, 1),
  (@q_id, 'Searching databases', 0, 2),
  (@q_id, 'Machine learning', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz74_id, 'What is quantum decoherence?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A quantum gate', 0, 0),
  (@q_id, 'The loss of quantum behavior due to interaction with the environment', 1, 1),
  (@q_id, 'A type of qubit', 0, 2),
  (@q_id, 'A quantum algorithm', 0, 3);

-- End Quiz 74: Quantum Computing Introduction

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, '5G and Future Networks', '5G technology and future networking', 'Networking', 30, 75.00);
SET @quiz75_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz75_id, 'What does 5G stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '5 Gigabit', 0, 0),
  (@q_id, 'Fifth Generation mobile network', 1, 1),
  (@q_id, '5 GHz network', 0, 2),
  (@q_id, 'Fifth Gigabit network', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz75_id, 'What is a key benefit of 5G over 4G?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Lower cost', 0, 0),
  (@q_id, 'Much higher bandwidth, lower latency, and more device connections', 1, 1),
  (@q_id, 'Better battery life', 0, 2),
  (@q_id, 'Wider coverage', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz75_id, 'What frequency bands does 5G use?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Only 5 GHz', 0, 0),
  (@q_id, 'Sub-6 GHz and millimeter wave (mmWave)', 1, 1),
  (@q_id, 'Only 2.4 GHz', 0, 2),
  (@q_id, 'Only 60 GHz', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz75_id, 'What is network slicing in 5G?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Cutting network cables', 0, 0),
  (@q_id, 'Creating multiple virtual networks on a shared physical infrastructure', 1, 1),
  (@q_id, 'A type of router', 0, 2),
  (@q_id, 'A security feature', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz75_id, 'What is latency in networking?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Bandwidth', 0, 0),
  (@q_id, 'The delay before data transfer begins', 1, 1),
  (@q_id, 'Packet loss', 0, 2),
  (@q_id, 'Network speed', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz75_id, 'What is mmWave in 5G?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of device', 0, 0),
  (@q_id, 'Very high frequency spectrum (24+ GHz) enabling ultra-high speed in 5G', 1, 1),
  (@q_id, 'A network slice', 0, 2),
  (@q_id, 'A type of antenna', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz75_id, 'What is a small cell in 5G?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A phone', 0, 0),
  (@q_id, 'A low-powered base station improving coverage and capacity', 1, 1),
  (@q_id, 'A type of SIM', 0, 2),
  (@q_id, 'A network slice', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz75_id, 'What is Massive MIMO?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of antenna', 0, 0),
  (@q_id, 'Using a large number of antennas to improve spectral efficiency', 1, 1),
  (@q_id, 'A network slice', 0, 2),
  (@q_id, 'A type of frequency', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz75_id, 'What industry can benefit most from 5G ultra-low latency?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Farming', 0, 0),
  (@q_id, 'Remote surgery and autonomous vehicles', 1, 1),
  (@q_id, 'Banking', 0, 2),
  (@q_id, 'Education', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz75_id, 'What is edge computing\'s role in 5G?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Replacing 5G', 0, 0),
  (@q_id, 'Processing data closer to users to reduce latency and backhaul', 1, 1),
  (@q_id, 'A type of frequency', 0, 2),
  (@q_id, 'A billing system', 0, 3);

-- End Quiz 75: 5G and Future Networks

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Augmented and Virtual Reality', 'AR and VR technology concepts', 'Emerging Technology', 30, 75.00);
SET @quiz76_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz76_id, 'What is Virtual Reality (VR)?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Partially overlaying digital content on real world', 0, 0),
  (@q_id, 'An immersive simulated environment blocking the real world', 1, 1),
  (@q_id, 'A type of monitor', 0, 2),
  (@q_id, 'A networking technology', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz76_id, 'What is Augmented Reality (AR)?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A fully virtual environment', 0, 0),
  (@q_id, 'Overlaying digital information onto the real world', 1, 1),
  (@q_id, 'A type of headset', 0, 2),
  (@q_id, 'A gaming console', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz76_id, 'What device is commonly used for VR experiences?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Smartphone only', 0, 0),
  (@q_id, 'A head-mounted display (HMD)', 1, 1),
  (@q_id, 'A smartwatch', 0, 2),
  (@q_id, 'A laptop', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz76_id, 'What is Mixed Reality (MR)?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Same as VR', 0, 0),
  (@q_id, 'A blend of physical and digital worlds where they interact in real time', 1, 1),
  (@q_id, 'Same as AR', 0, 2),
  (@q_id, 'A type of monitor', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz76_id, 'What is a major application of VR?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Email communication', 0, 0),
  (@q_id, 'Training simulations, gaming, and therapy', 1, 1),
  (@q_id, 'File storage', 0, 2),
  (@q_id, 'Database management', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz76_id, 'What is the FOV in a VR headset?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Frame Over Volume', 0, 0),
  (@q_id, 'Field of View — the extent of observable environment', 1, 1),
  (@q_id, 'Frequency of Vibration', 0, 2),
  (@q_id, 'Frame Output Value', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz76_id, 'What is spatial audio in VR?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Mono audio', 0, 0),
  (@q_id, '3D audio that simulates sound coming from specific directions', 1, 1),
  (@q_id, 'Background music', 0, 2),
  (@q_id, 'A type of microphone', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz76_id, 'What is haptic feedback in VR?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Visual feedback', 0, 0),
  (@q_id, 'Physical sensations (vibration, force) simulating touch', 1, 1),
  (@q_id, 'Audio feedback', 0, 2),
  (@q_id, 'Screen brightness changes', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz76_id, 'What is the purpose of inside-out tracking in VR?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Using external cameras', 0, 0),
  (@q_id, 'Using cameras on the headset to track position without external sensors', 1, 1),
  (@q_id, 'Tracking eye movements', 0, 2),
  (@q_id, 'Tracking hand gestures', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz76_id, 'What is the \'metaverse\'?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A video game', 0, 0),
  (@q_id, 'A persistent, shared virtual world combining VR, AR, and social elements', 1, 1),
  (@q_id, 'A type of VPN', 0, 2),
  (@q_id, 'A cloud service', 0, 3);

-- End Quiz 76: Augmented and Virtual Reality

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Biometric Technologies', 'Biometric authentication and identification', 'Emerging Technology', 30, 75.00);
SET @quiz77_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz77_id, 'What is biometrics?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of password', 0, 0),
  (@q_id, 'Measuring unique physical or behavioral characteristics for identification', 1, 1),
  (@q_id, 'A type of encryption', 0, 2),
  (@q_id, 'A network protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz77_id, 'What is fingerprint recognition?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Voice recognition', 0, 0),
  (@q_id, 'Identifying individuals by analyzing fingerprint patterns', 1, 1),
  (@q_id, 'Face recognition', 0, 2),
  (@q_id, 'Iris scanning', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz77_id, 'What is facial recognition?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Fingerprint scanning', 0, 0),
  (@q_id, 'Identifying individuals by analyzing facial features', 1, 1),
  (@q_id, 'Iris scanning', 0, 2),
  (@q_id, 'Voice recognition', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz77_id, 'What is iris recognition?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Fingerprint scanning', 0, 0),
  (@q_id, 'Identifying individuals by analyzing unique patterns in the iris of the eye', 1, 1),
  (@q_id, 'Face recognition', 0, 2),
  (@q_id, 'Retina scanning', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz77_id, 'What is voice recognition as a biometric?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Speech-to-text only', 0, 0),
  (@q_id, 'Authenticating or identifying individuals by their voice characteristics', 1, 1),
  (@q_id, 'A type of face recognition', 0, 2),
  (@q_id, 'Fingerprint scanning', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz77_id, 'What is behavioral biometrics?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Physical characteristics', 0, 0),
  (@q_id, 'Authentication based on patterns in behavior like typing rhythm or gait', 1, 1),
  (@q_id, 'A type of fingerprint', 0, 2),
  (@q_id, 'Voice recognition', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz77_id, 'What is a False Acceptance Rate (FAR) in biometrics?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Rate of rejection of valid users', 0, 0),
  (@q_id, 'Rate at which unauthorized users are incorrectly accepted', 1, 1),
  (@q_id, 'Failure to capture rate', 0, 2),
  (@q_id, 'None of the above', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz77_id, 'What is liveness detection in biometrics?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Checking fingerprint quality', 0, 0),
  (@q_id, 'Verifying the biometric is from a live person, not a photo or fake', 1, 1),
  (@q_id, 'A type of sensor', 0, 2),
  (@q_id, 'A database check', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz77_id, 'What regulation governs biometric data in Illinois, USA?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'GDPR', 0, 0),
  (@q_id, 'BIPA — Biometric Information Privacy Act', 1, 1),
  (@q_id, 'HIPAA', 0, 2),
  (@q_id, 'CCPA', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz77_id, 'What is multimodal biometrics?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Using one biometric', 0, 0),
  (@q_id, 'Combining multiple biometric methods to improve accuracy and security', 1, 1),
  (@q_id, 'A type of password', 0, 2),
  (@q_id, 'A single sensor', 0, 3);

-- End Quiz 77: Biometric Technologies

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Python Web Scraping', 'Web scraping with Python', 'Python', 30, 75.00);
SET @quiz78_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz78_id, 'What library is commonly used for web scraping in Python?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'pandas', 0, 0),
  (@q_id, 'BeautifulSoup', 1, 1),
  (@q_id, 'numpy', 0, 2),
  (@q_id, 'matplotlib', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz78_id, 'What does BeautifulSoup parse?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'CSV files', 0, 0),
  (@q_id, 'HTML and XML documents', 1, 1),
  (@q_id, 'JSON files', 0, 2),
  (@q_id, 'PDF files', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz78_id, 'What is the \'requests\' library used for?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Data analysis', 0, 0),
  (@q_id, 'Making HTTP requests in Python', 1, 1),
  (@q_id, 'Data visualization', 0, 2),
  (@q_id, 'Machine learning', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz78_id, 'What is Scrapy?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A data analysis tool', 0, 0),
  (@q_id, 'A Python framework for large-scale web scraping', 1, 1),
  (@q_id, 'A visualization library', 0, 2),
  (@q_id, 'A machine learning library', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz78_id, 'What does \'soup.find(\'div\', class_=\'content\')\' do?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Creates an HTML element', 0, 0),
  (@q_id, 'Finds the first div with class \'content\'', 1, 1),
  (@q_id, 'Deletes an element', 0, 2),
  (@q_id, 'Styles an element', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz78_id, 'What is robots.txt?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A webpage', 0, 0),
  (@q_id, 'A file telling crawlers which pages to avoid scraping', 1, 1),
  (@q_id, 'A Python library', 0, 2),
  (@q_id, 'A type of database', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz78_id, 'What is dynamic content scraping?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Scraping static HTML', 0, 0),
  (@q_id, 'Using tools like Selenium to scrape JS-rendered content', 1, 1),
  (@q_id, 'A type of parser', 0, 2),
  (@q_id, 'A Python function', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz78_id, 'What is rate limiting in scraping?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Parsing speed', 0, 0),
  (@q_id, 'Adding delays between requests to avoid overloading a server', 1, 1),
  (@q_id, 'A type of selector', 0, 2),
  (@q_id, 'A proxy technique', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz78_id, 'What is a CSS selector in web scraping?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A styling rule', 0, 0),
  (@q_id, 'A pattern used to select HTML elements for scraping', 1, 1),
  (@q_id, 'A Python library', 0, 2),
  (@q_id, 'A request method', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz78_id, 'What is Selenium used for in Python?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Data analysis', 0, 0),
  (@q_id, 'Browser automation allowing interaction with JavaScript-heavy pages', 1, 1),
  (@q_id, 'Machine learning', 0, 2),
  (@q_id, 'Database queries', 0, 3);

-- End Quiz 78: Python Web Scraping

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Database Indexing and Performance', 'Database indexing strategies and performance tuning', 'Database', 30, 75.00);
SET @quiz79_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz79_id, 'What is a database index?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A primary key', 0, 0),
  (@q_id, 'A data structure improving query speed by allowing fast lookups', 1, 1),
  (@q_id, 'A foreign key', 0, 2),
  (@q_id, 'A constraint', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz79_id, 'What is the downside of too many indexes?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Slower reads', 0, 0),
  (@q_id, 'Slower write operations and increased storage', 1, 1),
  (@q_id, 'Faster queries', 0, 2),
  (@q_id, 'No downside', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz79_id, 'What is a clustered index?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Any index', 0, 0),
  (@q_id, 'An index where data rows are stored in order of the index key', 1, 1),
  (@q_id, 'A secondary index', 0, 2),
  (@q_id, 'A composite index', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz79_id, 'What is a non-clustered index?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The primary index', 0, 0),
  (@q_id, 'An index with a separate structure pointing to data rows', 1, 1),
  (@q_id, 'A clustered index', 0, 2),
  (@q_id, 'A unique index', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz79_id, 'What is query optimization?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Writing more queries', 0, 0),
  (@q_id, 'Improving SQL queries to execute faster and use fewer resources', 1, 1),
  (@q_id, 'Adding more indexes', 0, 2),
  (@q_id, 'Removing constraints', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz79_id, 'What does EXPLAIN do in MySQL?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Executes a query', 0, 0),
  (@q_id, 'Shows how MySQL plans to execute a query (execution plan)', 1, 1),
  (@q_id, 'Creates an index', 0, 2),
  (@q_id, 'Shows table structure', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz79_id, 'What is a covering index?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'An index covering all tables', 0, 0),
  (@q_id, 'An index containing all columns needed to satisfy a query', 1, 1),
  (@q_id, 'A unique index', 0, 2),
  (@q_id, 'A composite key', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz79_id, 'What is query caching?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Storing query code', 0, 0),
  (@q_id, 'Storing results of queries so the same query doesn\'t re-execute', 1, 1),
  (@q_id, 'Adding indexes', 0, 2),
  (@q_id, 'Query optimization', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz79_id, 'What is connection pooling?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Increasing server RAM', 0, 0),
  (@q_id, 'Reusing database connections instead of creating new ones each time', 1, 1),
  (@q_id, 'A type of index', 0, 2),
  (@q_id, 'A type of cache', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz79_id, 'What is database sharding?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Merging databases', 0, 0),
  (@q_id, 'Horizontally partitioning a database across multiple servers', 1, 1),
  (@q_id, 'A type of index', 0, 2),
  (@q_id, 'A backup strategy', 0, 3);

-- End Quiz 79: Database Indexing and Performance

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Functional Programming Concepts', 'Introduction to functional programming', 'Programming', 30, 75.00);
SET @quiz80_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz80_id, 'What is functional programming?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'OOP variant', 0, 0),
  (@q_id, 'A paradigm treating computation as evaluation of mathematical functions', 1, 1),
  (@q_id, 'A type of loop', 0, 2),
  (@q_id, 'An OOP design pattern', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz80_id, 'What is a pure function?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Any function', 0, 0),
  (@q_id, 'A function that always returns the same output for the same input with no side effects', 1, 1),
  (@q_id, 'A recursive function', 0, 2),
  (@q_id, 'A lambda function', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz80_id, 'What is immutability in functional programming?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Data that changes often', 0, 0),
  (@q_id, 'Data that cannot be modified after creation', 1, 1),
  (@q_id, 'A type of variable', 0, 2),
  (@q_id, 'A recursive pattern', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz80_id, 'What is a higher-order function?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A complex function', 0, 0),
  (@q_id, 'A function that takes or returns other functions', 1, 1),
  (@q_id, 'A recursive function', 0, 2),
  (@q_id, 'A pure function', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz80_id, 'What is \'map\' in functional programming?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A dictionary', 0, 0),
  (@q_id, 'Applying a function to each element of a collection', 1, 1),
  (@q_id, 'A type of loop', 0, 2),
  (@q_id, 'A filter function', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz80_id, 'What is \'filter\' in functional programming?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Removing duplicates', 0, 0),
  (@q_id, 'Selecting elements from a collection that satisfy a predicate', 1, 1),
  (@q_id, 'Transforming elements', 0, 2),
  (@q_id, 'Reducing elements', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz80_id, 'What is \'reduce\' in functional programming?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Filtering a list', 0, 0),
  (@q_id, 'Combining elements of a collection into a single value', 1, 1),
  (@q_id, 'Mapping a function', 0, 2),
  (@q_id, 'Sorting a list', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz80_id, 'What is a lambda function?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A named function', 0, 0),
  (@q_id, 'An anonymous, inline function', 1, 1),
  (@q_id, 'A recursive function', 0, 2),
  (@q_id, 'A higher-order function', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz80_id, 'What is recursion?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of loop', 0, 0),
  (@q_id, 'A function calling itself to solve a problem', 1, 1),
  (@q_id, 'A higher-order function', 0, 2),
  (@q_id, 'A pure function', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz80_id, 'What is function composition?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Calling functions in parallel', 0, 0),
  (@q_id, 'Combining functions where output of one is input of the next', 1, 1),
  (@q_id, 'A type of recursion', 0, 2),
  (@q_id, 'A lambda function', 0, 3);

-- End Quiz 80: Functional Programming Concepts

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Computer Graphics Fundamentals', 'Introduction to computer graphics concepts', 'Computer Science', 30, 75.00);
SET @quiz81_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz81_id, 'What is rasterization?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A 3D modeling technique', 0, 0),
  (@q_id, 'Converting vector graphics into pixels for display', 1, 1),
  (@q_id, 'A type of shader', 0, 2),
  (@q_id, 'A ray tracing method', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz81_id, 'What is ray tracing?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of rasterization', 0, 0),
  (@q_id, 'Simulating light rays to produce realistic rendering', 1, 1),
  (@q_id, 'A type of texture', 0, 2),
  (@q_id, 'A polygon technique', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz81_id, 'What does GPU stand for?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Graphical Process Utility', 0, 0),
  (@q_id, 'Graphics Processing Unit designed for parallel rendering computations', 1, 1),
  (@q_id, 'General Purpose Unit', 0, 2),
  (@q_id, 'Graphics Pixel Unit', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz81_id, 'What is a texture in 3D graphics?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of polygon', 0, 0),
  (@q_id, 'An image mapped onto a 3D surface to add detail', 1, 1),
  (@q_id, 'A type of light', 0, 2),
  (@q_id, 'A shader type', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz81_id, 'What is a polygon in 3D graphics?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of shader', 0, 0),
  (@q_id, 'A flat 2D shape used to construct 3D models', 1, 1),
  (@q_id, 'A texture type', 0, 2),
  (@q_id, 'A rendering algorithm', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz81_id, 'What is a shader?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of polygon', 0, 0),
  (@q_id, 'A program running on the GPU to determine color and lighting of pixels', 1, 1),
  (@q_id, 'A type of texture', 0, 2),
  (@q_id, 'A 3D model format', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz81_id, 'What does OpenGL stand for?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Open Graphical Language', 0, 0),
  (@q_id, 'Open Graphics Library — a cross-platform graphics API', 1, 1),
  (@q_id, 'Open General Layer', 0, 2),
  (@q_id, 'Open GPU Logic', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz81_id, 'What is anti-aliasing?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Reducing texture quality', 0, 0),
  (@q_id, 'A technique smoothing jagged edges in rendered images', 1, 1),
  (@q_id, 'A type of shader', 0, 2),
  (@q_id, 'A rendering algorithm', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz81_id, 'What is a frame buffer?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of GPU', 0, 0),
  (@q_id, 'Memory storing a complete frame of image data for display', 1, 1),
  (@q_id, 'A type of shader', 0, 2),
  (@q_id, 'A polygon mesh', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz81_id, 'What is LOD in 3D graphics?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Light on Display', 0, 0),
  (@q_id, 'Level of Detail — reducing polygon count for distant objects', 1, 1),
  (@q_id, 'Line of Direction', 0, 2),
  (@q_id, 'Layer of Depth', 0, 3);

-- End Quiz 81: Computer Graphics Fundamentals

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Agile Testing and QA', 'Testing in Agile development', 'Software Engineering', 30, 75.00);
SET @quiz82_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz82_id, 'What is continuous testing in Agile?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Testing only at release', 0, 0),
  (@q_id, 'Running automated tests throughout development to detect issues early', 1, 1),
  (@q_id, 'Manual testing only', 0, 2),
  (@q_id, 'Testing at sprint end', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz82_id, 'What is exploratory testing?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Following a test script', 0, 0),
  (@q_id, 'Simultaneous learning, test design, and execution without a fixed script', 1, 1),
  (@q_id, 'Automated testing', 0, 2),
  (@q_id, 'Performance testing', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz82_id, 'What is a test-driven development cycle?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Write code then tests', 1, 0),
  (@q_id, 'Write failing test → write code to pass → refactor', 0, 1),
  (@q_id, 'Run tests then write code', 0, 2),
  (@q_id, 'Deploy then test', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz82_id, 'What is behavior-driven development (BDD)?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Test-first development', 0, 0),
  (@q_id, 'Writing tests in natural language describing system behavior', 1, 1),
  (@q_id, 'Performance testing', 0, 2),
  (@q_id, 'Manual testing', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz82_id, 'What tool is used for BDD in Java?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'JUnit', 0, 0),
  (@q_id, 'Cucumber — enabling tests written in Gherkin natural language', 1, 1),
  (@q_id, 'Selenium', 0, 2),
  (@q_id, 'Mockito', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz82_id, 'What is a mock object in testing?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A real object', 0, 0),
  (@q_id, 'A simulated object replacing real dependencies in unit tests', 1, 1),
  (@q_id, 'A test case', 0, 2),
  (@q_id, 'A test environment', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz82_id, 'What is code coverage?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Number of bugs found', 0, 0),
  (@q_id, 'The percentage of source code executed during testing', 1, 1),
  (@q_id, 'Number of tests', 0, 2),
  (@q_id, 'Lines of code', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz82_id, 'What is smoke testing?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Testing all features', 0, 0),
  (@q_id, 'A quick test verifying basic functionality before deeper testing', 1, 1),
  (@q_id, 'Performance testing', 0, 2),
  (@q_id, 'Security testing', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz82_id, 'What is regression testing in Agile?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Testing new features', 0, 0),
  (@q_id, 'Verifying that changes haven\'t broken existing functionality', 1, 1),
  (@q_id, 'Load testing', 0, 2),
  (@q_id, 'Smoke testing', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz82_id, 'What is the purpose of a test plan?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'To list bugs', 0, 0),
  (@q_id, 'To document the scope, approach, and schedule for testing activities', 1, 1),
  (@q_id, 'To write code', 0, 2),
  (@q_id, 'To deploy software', 0, 3);

-- End Quiz 82: Agile Testing and QA

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Computer Science Theory', 'Theoretical computer science concepts', 'Computer Science', 30, 75.00);
SET @quiz83_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz83_id, 'What is a Turing machine?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A real machine', 0, 0),
  (@q_id, 'A theoretical model of computation used to define algorithms', 1, 1),
  (@q_id, 'A type of computer', 0, 2),
  (@q_id, 'A programming language', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz83_id, 'What is computational complexity?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Speed of a CPU', 0, 0),
  (@q_id, 'The study of resources (time/space) required to solve computational problems', 1, 1),
  (@q_id, 'A type of algorithm', 0, 2),
  (@q_id, 'A programming paradigm', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz83_id, 'What does Big O notation represent?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Exact runtime', 0, 0),
  (@q_id, 'The upper bound on the growth rate of an algorithm\'s resource usage', 1, 1),
  (@q_id, 'Exact memory usage', 0, 2),
  (@q_id, 'A type of sorting', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz83_id, 'What is the P vs NP problem?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'An easy problem', 0, 0),
  (@q_id, 'A major unsolved problem asking if every verifiable problem can be solved quickly', 1, 1),
  (@q_id, 'A solved theorem', 0, 2),
  (@q_id, 'A type of algorithm', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz83_id, 'What is a finite automaton?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of computer', 0, 0),
  (@q_id, 'A mathematical model with states and transitions for pattern recognition', 1, 1),
  (@q_id, 'A sorting algorithm', 0, 2),
  (@q_id, 'A type of loop', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz83_id, 'What is a regular language?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A natural language', 0, 0),
  (@q_id, 'A language recognized by a finite automaton', 1, 1),
  (@q_id, 'A programming language', 0, 2),
  (@q_id, 'A database language', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz83_id, 'What is the halting problem?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A sorting problem', 0, 0),
  (@q_id, 'The undecidable problem of whether a program will halt for given input', 1, 1),
  (@q_id, 'A search problem', 0, 2),
  (@q_id, 'An NP problem', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz83_id, 'What is a context-free grammar?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A grammar without rules', 0, 0),
  (@q_id, 'A grammar with rules where a non-terminal can be replaced by sequences', 1, 1),
  (@q_id, 'A regular grammar', 0, 2),
  (@q_id, 'A Turing machine', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz83_id, 'What is NP-complete?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The easiest problems', 0, 0),
  (@q_id, 'Problems that are both in NP and as hard as the hardest NP problems', 1, 1),
  (@q_id, 'Solved problems', 0, 2),
  (@q_id, 'Linear-time problems', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz83_id, 'What is a greedy algorithm?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Always correct algorithm', 0, 0),
  (@q_id, 'An algorithm making locally optimal choices at each step', 1, 1),
  (@q_id, 'A divide-and-conquer algorithm', 0, 2),
  (@q_id, 'A dynamic programming method', 0, 3);

-- End Quiz 83: Computer Science Theory

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Linux Shell Scripting', 'Shell scripting in Linux', 'Linux', 30, 75.00);
SET @quiz84_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz84_id, 'What is the shebang line in a shell script?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A comment', 0, 0),
  (@q_id, 'The first line (#!/bin/bash) specifying the interpreter', 1, 1),
  (@q_id, 'A variable', 0, 2),
  (@q_id, 'A function', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz84_id, 'How do you declare a variable in bash?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'var x=5', 0, 0),
  (@q_id, 'x = 5', 0, 1),
  (@q_id, 'x=5', 1, 2),
  (@q_id, 'let x=5', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz84_id, 'What does \'$?\' represent in bash?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The script name', 0, 0),
  (@q_id, 'The exit status of the last command', 1, 1),
  (@q_id, 'A special variable', 0, 2),
  (@q_id, 'The PID of last process', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz84_id, 'What is a for loop in bash?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'for x in list do ... done', 1, 0),
  (@q_id, 'for(x in list) {...}', 0, 1),
  (@q_id, 'foreach x in list {...}', 0, 2),
  (@q_id, 'for x of list {...}', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz84_id, 'What does \'echo\' do in bash?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Reads input', 0, 0),
  (@q_id, 'Prints text to standard output', 1, 1),
  (@q_id, 'Creates a file', 0, 2),
  (@q_id, 'Runs a command', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz84_id, 'What does \'> file.txt\' do in bash?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Appends to file', 0, 0),
  (@q_id, 'Redirects output to file.txt, overwriting it', 1, 1),
  (@q_id, 'Reads from file', 0, 2),
  (@q_id, 'Creates a directory', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz84_id, 'What does \'>>\' do in bash?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Overwrites file', 0, 0),
  (@q_id, 'Appends output to a file', 1, 1),
  (@q_id, 'Reads from a file', 0, 2),
  (@q_id, 'Pipes output', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz84_id, 'What is a pipe (|) in bash?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A file operator', 0, 0),
  (@q_id, 'Sends output of one command as input to another', 1, 1),
  (@q_id, 'A comment', 0, 2),
  (@q_id, 'A variable', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz84_id, 'What does \'chmod +x script.sh\' do?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Delete a script', 0, 0),
  (@q_id, 'Make a script executable', 1, 1),
  (@q_id, 'Create a script', 0, 2),
  (@q_id, 'Show script content', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz84_id, 'What is a conditional in bash?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of loop', 0, 0),
  (@q_id, 'An if-then-else statement checking conditions', 1, 1),
  (@q_id, 'A function', 0, 2),
  (@q_id, 'A variable', 0, 3);

-- End Quiz 84: Linux Shell Scripting

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Cybersecurity Incident Response', 'Incident response procedures', 'Cybersecurity', 30, 75.00);
SET @quiz85_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz85_id, 'What is incident response?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Preventing all attacks', 0, 0),
  (@q_id, 'A structured approach to handling and recovering from cybersecurity incidents', 1, 1),
  (@q_id, 'Writing security policies', 0, 2),
  (@q_id, 'Installing antivirus', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz85_id, 'What is the first step in incident response?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Eradication', 0, 0),
  (@q_id, 'Preparation — planning and training before incidents occur', 1, 1),
  (@q_id, 'Recovery', 0, 2),
  (@q_id, 'Identification', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz85_id, 'What is the identification phase of incident response?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Fixing the incident', 0, 0),
  (@q_id, 'Detecting and determining if an event is a security incident', 1, 1),
  (@q_id, 'Recovering systems', 0, 2),
  (@q_id, 'Documenting findings', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz85_id, 'What is containment in incident response?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Deleting infected systems', 0, 0),
  (@q_id, 'Limiting the scope and impact of an incident', 1, 1),
  (@q_id, 'Recovering data', 0, 2),
  (@q_id, 'Identifying the attacker', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz85_id, 'What is eradication in incident response?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Rebuilding systems', 0, 0),
  (@q_id, 'Removing the root cause of the incident (malware, vulnerabilities)', 1, 1),
  (@q_id, 'Documenting the incident', 0, 2),
  (@q_id, 'Notifying users', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz85_id, 'What is recovery in incident response?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Finding root cause', 0, 0),
  (@q_id, 'Restoring affected systems to normal operations', 1, 1),
  (@q_id, 'Identifying attackers', 0, 2),
  (@q_id, 'Documenting findings', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz85_id, 'What is a post-incident review?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Initial alert', 0, 0),
  (@q_id, 'Analyzing what happened and how to improve after an incident', 1, 1),
  (@q_id, 'System recovery', 0, 2),
  (@q_id, 'Incident containment', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz85_id, 'What is a chain of custody?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A security protocol', 0, 0),
  (@q_id, 'Documentation tracking evidence handling throughout an investigation', 1, 1),
  (@q_id, 'A type of firewall', 0, 2),
  (@q_id, 'A backup procedure', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz85_id, 'What is digital forensics?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A cybersecurity attack', 0, 0),
  (@q_id, 'The collection and analysis of digital evidence for investigations', 1, 1),
  (@q_id, 'A type of firewall', 0, 2),
  (@q_id, 'An incident prevention method', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz85_id, 'What is the purpose of an incident response plan?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Prevent all incidents', 0, 0),
  (@q_id, 'Provide a roadmap for responding to security incidents effectively', 1, 1),
  (@q_id, 'Install antivirus', 0, 2),
  (@q_id, 'Test backups', 0, 3);

-- End Quiz 85: Cybersecurity Incident Response

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Cloud Databases and Storage', 'Cloud-based database and storage services', 'Cloud Computing', 30, 75.00);
SET @quiz86_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz86_id, 'What is Amazon DynamoDB?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A relational database', 0, 0),
  (@q_id, 'A managed NoSQL database service on AWS', 1, 1),
  (@q_id, 'A file storage service', 0, 2),
  (@q_id, 'A caching service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz86_id, 'What is Google BigQuery?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A relational database', 0, 0),
  (@q_id, 'A serverless data warehouse for analytics on large datasets', 1, 1),
  (@q_id, 'A key-value store', 0, 2),
  (@q_id, 'A file storage', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz86_id, 'What is Amazon S3 used for?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Running virtual machines', 0, 0),
  (@q_id, 'Scalable object storage for files, images, and backups', 1, 1),
  (@q_id, 'A database service', 0, 2),
  (@q_id, 'A networking service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz86_id, 'What is Azure Blob Storage?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A SQL database', 0, 0),
  (@q_id, 'Microsoft\'s object storage service for unstructured data', 1, 1),
  (@q_id, 'A virtual machine', 0, 2),
  (@q_id, 'A CDN service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz86_id, 'What is Cloud SQL?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A NoSQL service', 0, 0),
  (@q_id, 'A managed relational database service in the cloud', 1, 1),
  (@q_id, 'A file storage', 0, 2),
  (@q_id, 'An analytics tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz86_id, 'What is a database replica?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A backup file', 0, 0),
  (@q_id, 'A copy of a database kept synchronized for redundancy or read scaling', 1, 1),
  (@q_id, 'A database index', 0, 2),
  (@q_id, 'A stored procedure', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz86_id, 'What is database-as-a-service (DBaaS)?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A self-managed database', 0, 0),
  (@q_id, 'A cloud service providing managed database infrastructure', 1, 1),
  (@q_id, 'A type of NoSQL', 0, 2),
  (@q_id, 'An on-premises database', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz86_id, 'What is Cold Storage in cloud?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'High-speed storage', 0, 0),
  (@q_id, 'Low-cost archival storage for infrequently accessed data', 1, 1),
  (@q_id, 'A type of SSD', 0, 2),
  (@q_id, 'A caching layer', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz86_id, 'What is Amazon Aurora?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A NoSQL database', 0, 0),
  (@q_id, 'A MySQL and PostgreSQL-compatible relational database by AWS', 1, 1),
  (@q_id, 'A caching service', 0, 2),
  (@q_id, 'A file storage', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz86_id, 'What is the purpose of a CDN in cloud storage?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Stores all data', 0, 0),
  (@q_id, 'Distributes content geographically to serve users faster', 1, 1),
  (@q_id, 'A database service', 0, 2),
  (@q_id, 'A compute service', 0, 3);

-- End Quiz 86: Cloud Databases and Storage

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Microservices Architecture', 'Microservices design patterns and concepts', 'Software Engineering', 30, 75.00);
SET @quiz87_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz87_id, 'What is microservices architecture?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A monolithic design', 0, 0),
  (@q_id, 'A style where apps are built as small, independently deployable services', 1, 1),
  (@q_id, 'A type of database', 0, 2),
  (@q_id, 'A frontend framework', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz87_id, 'What is a monolithic architecture?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Multiple small services', 0, 0),
  (@q_id, 'A single unified application where all components are interconnected', 1, 1),
  (@q_id, 'A type of database', 0, 2),
  (@q_id, 'A cloud service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz87_id, 'What is a benefit of microservices over monolith?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Simpler codebase', 0, 0),
  (@q_id, 'Independent deployment, scaling, and development of services', 1, 1),
  (@q_id, 'Fewer servers needed', 0, 2),
  (@q_id, 'Single language requirement', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz87_id, 'What is an API gateway in microservices?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of database', 0, 0),
  (@q_id, 'A single entry point routing requests to appropriate microservices', 1, 1),
  (@q_id, 'A monitoring tool', 0, 2),
  (@q_id, 'A load balancer only', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz87_id, 'What is service discovery in microservices?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Finding bugs', 0, 0),
  (@q_id, 'Enabling services to find and communicate with each other dynamically', 1, 1),
  (@q_id, 'A type of database', 0, 2),
  (@q_id, 'A monitoring system', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz87_id, 'What is a circuit breaker pattern?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A hardware component', 0, 0),
  (@q_id, 'A pattern preventing cascading failures when a service is unavailable', 1, 1),
  (@q_id, 'A type of API', 0, 2),
  (@q_id, 'A load balancer', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz87_id, 'What is an event bus in microservices?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of database', 0, 0),
  (@q_id, 'A communication channel for services to publish and subscribe to events', 1, 1),
  (@q_id, 'A type of API gateway', 0, 2),
  (@q_id, 'A monitoring tool', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz87_id, 'What is the Saga pattern in microservices?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of database', 0, 0),
  (@q_id, 'Managing distributed transactions through a sequence of local transactions', 1, 1),
  (@q_id, 'A type of API', 0, 2),
  (@q_id, 'A circuit breaker', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz87_id, 'What is containerization\'s role in microservices?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'It\'s not related', 0, 0),
  (@q_id, 'Containers isolate and package each microservice for consistent deployment', 1, 1),
  (@q_id, 'It replaces microservices', 0, 2),
  (@q_id, 'It\'s only for databases', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz87_id, 'What is service mesh?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of database', 0, 0),
  (@q_id, 'Infrastructure managing service-to-service communication in microservices', 1, 1),
  (@q_id, 'A type of API gateway', 0, 2),
  (@q_id, 'A monitoring tool', 0, 3);

-- End Quiz 87: Microservices Architecture

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Embedded Systems Basics', 'Introduction to embedded systems', 'Hardware', 30, 75.00);
SET @quiz88_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz88_id, 'What is an embedded system?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of PC', 0, 0),
  (@q_id, 'A specialized computer system designed for a specific function within a larger system', 1, 1),
  (@q_id, 'A type of OS', 0, 2),
  (@q_id, 'A type of database', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz88_id, 'What is a microcontroller?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of CPU', 0, 0),
  (@q_id, 'A compact IC containing a processor, memory, and I/O in one chip', 1, 1),
  (@q_id, 'A type of GPU', 0, 2),
  (@q_id, 'A type of RAM', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz88_id, 'What is Arduino?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A programming language', 0, 0),
  (@q_id, 'An open-source microcontroller platform popular for prototyping', 1, 1),
  (@q_id, 'A type of OS', 0, 2),
  (@q_id, 'A cloud service', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz88_id, 'What is Raspberry Pi?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of database', 0, 0),
  (@q_id, 'A small single-board computer used for learning and IoT projects', 1, 1),
  (@q_id, 'A type of microcontroller', 0, 2),
  (@q_id, 'A type of GPU', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz88_id, 'What language is commonly used in Arduino programming?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Python', 0, 0),
  (@q_id, 'C/C++', 1, 1),
  (@q_id, 'Java', 0, 2),
  (@q_id, 'PHP', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz88_id, 'What is firmware?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Application software', 0, 0),
  (@q_id, 'Low-level software embedded in hardware devices to control them', 1, 1),
  (@q_id, 'An operating system', 0, 2),
  (@q_id, 'A type of database', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz88_id, 'What is RTOS?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of database', 0, 0),
  (@q_id, 'Real-Time Operating System — an OS guaranteeing response within time constraints', 1, 1),
  (@q_id, 'A type of CPU', 0, 2),
  (@q_id, 'A type of RAM', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz88_id, 'What is GPIO?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of database', 0, 0),
  (@q_id, 'General Purpose Input/Output — pins on a microcontroller for interfacing', 1, 1),
  (@q_id, 'A type of CPU', 0, 2),
  (@q_id, 'A type of RAM', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz88_id, 'What is PWM in embedded systems?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Power with Memory', 0, 0),
  (@q_id, 'Pulse Width Modulation — controlling power delivery to devices like motors', 1, 1),
  (@q_id, 'A type of communication', 0, 2),
  (@q_id, 'A network protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz88_id, 'What is UART?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of OS', 0, 0),
  (@q_id, 'Universal Asynchronous Receiver-Transmitter — a serial communication protocol', 1, 1),
  (@q_id, 'A type of memory', 0, 2),
  (@q_id, 'A type of sensor', 0, 3);

-- End Quiz 88: Embedded Systems Basics

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'TypeScript Fundamentals', 'Core TypeScript language features', 'Programming', 30, 75.00);
SET @quiz89_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz89_id, 'What is TypeScript?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A new programming language', 0, 0),
  (@q_id, 'A typed superset of JavaScript that compiles to plain JavaScript', 1, 1),
  (@q_id, 'A backend framework', 0, 2),
  (@q_id, 'A CSS preprocessor', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz89_id, 'Which file extension do TypeScript files use?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '.js', 0, 0),
  (@q_id, '.ts', 1, 1),
  (@q_id, '.tsx', 0, 2),
  (@q_id, '.jsx', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz89_id, 'What does \'strict mode\' enable in TypeScript?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Faster compilation', 0, 0),
  (@q_id, 'Stricter type checking rules', 1, 1),
  (@q_id, 'A new runtime', 0, 2),
  (@q_id, 'Automatic formatting', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz89_id, 'How do you declare a typed variable in TypeScript?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'var x = 5', 0, 0),
  (@q_id, 'let x: number = 5', 1, 1),
  (@q_id, 'int x = 5', 0, 2),
  (@q_id, 'number x = 5;', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz89_id, 'What is an interface in TypeScript?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A class', 0, 0),
  (@q_id, 'A contract describing the shape of an object', 1, 1),
  (@q_id, 'A function type', 0, 2),
  (@q_id, 'A module', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz89_id, 'What is \'any\' type in TypeScript?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The default type', 0, 0),
  (@q_id, 'A type that disables type checking for a variable', 1, 1),
  (@q_id, 'A union type', 0, 2),
  (@q_id, 'An object type', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz89_id, 'What is a union type in TypeScript?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type that is any', 0, 0),
  (@q_id, 'A type that can be one of several specified types', 1, 1),
  (@q_id, 'An intersection type', 0, 2),
  (@q_id, 'A generic type', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz89_id, 'What are generics in TypeScript?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of interface', 0, 0),
  (@q_id, 'Reusable components that work with a variety of types', 1, 1),
  (@q_id, 'A type of any', 0, 2),
  (@q_id, 'A module', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz89_id, 'What does \'readonly\' mean in TypeScript?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The variable is a constant', 0, 0),
  (@q_id, 'A property cannot be modified after initialization', 1, 1),
  (@q_id, 'A type of interface', 0, 2),
  (@q_id, 'A module', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz89_id, 'What is type inference in TypeScript?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Manual type declaration', 0, 0),
  (@q_id, 'TypeScript automatically deducing the type based on the assigned value', 1, 1),
  (@q_id, 'A compiler setting', 0, 2),
  (@q_id, 'A generic type', 0, 3);

-- End Quiz 89: TypeScript Fundamentals

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'PHP Web Development', 'PHP programming for web development', 'Web Development', 30, 75.00);
SET @quiz90_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz90_id, 'What does PHP stand for?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Personal Home Page', 0, 0),
  (@q_id, 'PHP: Hypertext Preprocessor', 1, 1),
  (@q_id, 'Preprocessed HTML Pages', 0, 2),
  (@q_id, 'Public Home Protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz90_id, 'Which symbol starts a PHP variable?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '@', 0, 0),
  (@q_id, '$', 1, 1),
  (@q_id, '#', 0, 2),
  (@q_id, '&', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz90_id, 'Which function outputs text in PHP?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'print_line()', 0, 0),
  (@q_id, 'console.log()', 0, 1),
  (@q_id, 'echo', 1, 2),
  (@q_id, 'output()', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz90_id, 'What does $_GET contain in PHP?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'POST data', 0, 0),
  (@q_id, 'URL query string parameters', 1, 1),
  (@q_id, 'Session data', 0, 2),
  (@q_id, 'Cookie data', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz90_id, 'What does $_POST contain?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'URL parameters', 0, 0),
  (@q_id, 'Data sent via HTTP POST form submission', 1, 1),
  (@q_id, 'Session data', 0, 2),
  (@q_id, 'Server variables', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz90_id, 'Which PHP function connects to a MySQL database using PDO?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'mysql_connect()', 0, 0),
  (@q_id, 'new PDO()', 1, 1),
  (@q_id, 'mysqli_connect()', 0, 2),
  (@q_id, 'db_connect()', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz90_id, 'What is the purpose of session_start() in PHP?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Start the server', 0, 0),
  (@q_id, 'Initialize or resume a session', 1, 1),
  (@q_id, 'Connect to a database', 0, 2),
  (@q_id, 'Load a config file', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz90_id, 'Which function sanitizes user input in PHP?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'clean()', 0, 0),
  (@q_id, 'htmlspecialchars()', 1, 1),
  (@q_id, 'sanitize()', 0, 2),
  (@q_id, 'strip_input()', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz90_id, 'What does \'include\' do in PHP?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Imports a class', 0, 0),
  (@q_id, 'Includes and evaluates a specified file', 1, 1),
  (@q_id, 'Creates a function', 0, 2),
  (@q_id, 'Defines a constant', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz90_id, 'What is Composer in PHP?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A code editor', 0, 0),
  (@q_id, 'A dependency manager for PHP packages', 1, 1),
  (@q_id, 'A testing tool', 0, 2),
  (@q_id, 'A PHP framework', 0, 3);

-- End Quiz 90: PHP Web Development

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Computer Networks: IPv6', 'IPv6 addressing and features', 'Networking', 30, 75.00);
SET @quiz91_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz91_id, 'How many bits is an IPv6 address?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '32', 0, 0),
  (@q_id, '64', 0, 1),
  (@q_id, '128', 1, 2),
  (@q_id, '256', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz91_id, 'What is the purpose of IPv6?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Replace IPv4', 0, 0),
  (@q_id, 'Solve IPv4 address exhaustion by providing more addresses', 1, 1),
  (@q_id, 'Speed up routing', 0, 2),
  (@q_id, 'Improve security', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz91_id, 'What notation is used for IPv6 addresses?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Dotted decimal', 0, 0),
  (@q_id, 'Hexadecimal groups separated by colons', 1, 1),
  (@q_id, 'Binary', 0, 2),
  (@q_id, 'Octal', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz91_id, 'What does \'::\' represent in IPv6?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A routing prefix', 0, 0),
  (@q_id, 'One or more groups of zeros compressed', 1, 1),
  (@q_id, 'A network mask', 0, 2),
  (@q_id, 'A broadcast address', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz91_id, 'What is the IPv6 loopback address?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '127.0.0.1', 0, 0),
  (@q_id, '::1', 1, 1),
  (@q_id, '0.0.0.0', 0, 2),
  (@q_id, 'fe80::1', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz91_id, 'What is a link-local IPv6 address prefix?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '2001::', 0, 0),
  (@q_id, 'fe80::/10', 1, 1),
  (@q_id, 'fc00::/7', 0, 2),
  (@q_id, '::1/128', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz91_id, 'What is SLAAC in IPv6?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Stateless Address Autoconfiguration — devices configure their own addresses', 1, 0),
  (@q_id, 'Static Link Address Assignment', 0, 1),
  (@q_id, 'Secure Local Address Assignment', 0, 2),
  (@q_id, 'Simple Layer Address Automation', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz91_id, 'What replaced ARP in IPv6?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'DNS', 0, 0),
  (@q_id, 'NDP — Neighbor Discovery Protocol', 1, 1),
  (@q_id, 'DHCP', 0, 2),
  (@q_id, 'ICMP', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz91_id, 'What is the IPv6 multicast prefix?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, '2001::', 0, 0),
  (@q_id, 'fc00::', 0, 1),
  (@q_id, 'ff00::/8', 1, 2),
  (@q_id, 'fe80::', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz91_id, 'What type of address is 2001:db8::/32 commonly used for?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Production routing', 0, 0),
  (@q_id, 'Documentation and examples', 1, 1),
  (@q_id, 'Loopback', 0, 2),
  (@q_id, 'Link-local', 0, 3);

-- End Quiz 91: Computer Networks: IPv6

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Software Deployment and Release', 'Deployment strategies and release management', 'Software Engineering', 30, 75.00);
SET @quiz92_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz92_id, 'What is a software release?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A bug fix only', 0, 0),
  (@q_id, 'A version of software made available to users', 1, 1),
  (@q_id, 'A code review', 0, 2),
  (@q_id, 'A test run', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz92_id, 'What is canary deployment?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Deploying to all users', 0, 0),
  (@q_id, 'Gradually rolling out to a small subset of users first', 1, 1),
  (@q_id, 'A type of rollback', 0, 2),
  (@q_id, 'A blue-green variant', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz92_id, 'What is feature flagging?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of bug', 0, 0),
  (@q_id, 'Toggling features on/off without deploying new code', 1, 1),
  (@q_id, 'A deployment strategy', 0, 2),
  (@q_id, 'A type of test', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz92_id, 'What is a hotfix?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A planned update', 0, 0),
  (@q_id, 'An urgent fix deployed to production for a critical issue', 1, 1),
  (@q_id, 'A feature release', 0, 2),
  (@q_id, 'A test deployment', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz92_id, 'What is semantic versioning (SemVer)?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Any version format', 0, 0),
  (@q_id, 'A versioning scheme: MAJOR.MINOR.PATCH indicating type of change', 1, 1),
  (@q_id, 'A deployment tool', 0, 2),
  (@q_id, 'A branching strategy', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz92_id, 'What does \'release candidate\' (RC) mean?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Final version', 0, 0),
  (@q_id, 'A version potentially ready for release pending final testing', 1, 1),
  (@q_id, 'A beta version', 0, 2),
  (@q_id, 'An alpha version', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz92_id, 'What is A/B testing in deployment?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Testing code quality', 0, 0),
  (@q_id, 'Comparing two versions with different user groups to measure performance', 1, 1),
  (@q_id, 'A type of rollback', 0, 2),
  (@q_id, 'A monitoring strategy', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz92_id, 'What is environment parity?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Making all environments identical', 0, 0),
  (@q_id, 'Keeping development, staging, and production as similar as possible', 1, 1),
  (@q_id, 'A deployment pipeline', 0, 2),
  (@q_id, 'A release schedule', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz92_id, 'What does \'immutable infrastructure\' mean?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Never changing servers', 0, 0),
  (@q_id, 'Servers are replaced rather than updated when changes are needed', 1, 1),
  (@q_id, 'A type of monitoring', 0, 2),
  (@q_id, 'A database approach', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz92_id, 'What is a deployment pipeline?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of database', 0, 0),
  (@q_id, 'Automated steps taking code from source control to production', 1, 1),
  (@q_id, 'A monitoring tool', 0, 2),
  (@q_id, 'A version control system', 0, 3);

-- End Quiz 92: Software Deployment and Release

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Database Administration', 'Database administration tasks and concepts', 'Database', 30, 75.00);
SET @quiz93_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz93_id, 'What is the role of a DBA?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Write application code', 0, 0),
  (@q_id, 'Manage, maintain, and secure database systems', 1, 1),
  (@q_id, 'Design user interfaces', 0, 2),
  (@q_id, 'Handle network configurations', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz93_id, 'What is a database backup?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Deleting old records', 0, 0),
  (@q_id, 'A copy of data stored to recover from loss or corruption', 1, 1),
  (@q_id, 'An index strategy', 0, 2),
  (@q_id, 'A performance test', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz93_id, 'What is point-in-time recovery?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Restoring from weekly backup', 0, 0),
  (@q_id, 'Restoring a database to any specific point in time', 1, 1),
  (@q_id, 'Backing up in real time', 0, 2),
  (@q_id, 'An indexing strategy', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz93_id, 'What is database replication?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Duplicating tables', 0, 0),
  (@q_id, 'Copying data to multiple servers for redundancy or performance', 1, 1),
  (@q_id, 'A type of backup', 0, 2),
  (@q_id, 'A normalization technique', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz93_id, 'What is a tablespace in databases?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of table', 0, 0),
  (@q_id, 'A logical storage container grouping database objects', 1, 1),
  (@q_id, 'A database schema', 0, 2),
  (@q_id, 'A type of index', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz93_id, 'What is database monitoring?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Watching server hardware', 0, 0),
  (@q_id, 'Tracking database performance, queries, and resource usage', 1, 1),
  (@q_id, 'A type of backup', 0, 2),
  (@q_id, 'A normalization task', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz93_id, 'What is a slow query log?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of backup', 0, 0),
  (@q_id, 'A log recording queries that exceed a threshold execution time', 1, 1),
  (@q_id, 'A database schema', 0, 2),
  (@q_id, 'A replication log', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz93_id, 'What is database archiving?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Deleting old data', 0, 0),
  (@q_id, 'Moving old data to separate storage while keeping it accessible', 1, 1),
  (@q_id, 'A type of backup', 0, 2),
  (@q_id, 'A normalization technique', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz93_id, 'What is a database trigger?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of index', 0, 0),
  (@q_id, 'A stored procedure that automatically executes on a specific event', 1, 1),
  (@q_id, 'A type of view', 0, 2),
  (@q_id, 'A foreign key', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz93_id, 'What is a stored procedure?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of view', 0, 0),
  (@q_id, 'A precompiled SQL code block stored in the database and executed by name', 1, 1),
  (@q_id, 'A type of index', 0, 2),
  (@q_id, 'A database backup', 0, 3);

-- End Quiz 93: Database Administration

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Information Security Management', 'Managing information security in organizations', 'Cybersecurity', 30, 75.00);
SET @quiz94_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz94_id, 'What is an ISMS?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Internet Security Management Software', 0, 0),
  (@q_id, 'Information Security Management System — a framework for managing security', 1, 1),
  (@q_id, 'Internal Security Monitoring System', 0, 2),
  (@q_id, 'Integrated Security Management Software', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz94_id, 'What is ISO 27001?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A network standard', 0, 0),
  (@q_id, 'An international standard for information security management', 1, 1),
  (@q_id, 'A programming standard', 0, 2),
  (@q_id, 'A cloud standard', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz94_id, 'What is a security policy?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A firewall rule', 0, 0),
  (@q_id, 'A document defining rules and practices for protecting information', 1, 1),
  (@q_id, 'A type of encryption', 0, 2),
  (@q_id, 'An access control list', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz94_id, 'What is risk assessment in information security?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Eliminating all risks', 0, 0),
  (@q_id, 'Identifying, analyzing, and evaluating risks to information assets', 1, 1),
  (@q_id, 'A type of firewall', 0, 2),
  (@q_id, 'A backup strategy', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz94_id, 'What is a BCP?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Business Control Protocol', 0, 0),
  (@q_id, 'Business Continuity Plan — ensuring operations continue during disruptions', 1, 1),
  (@q_id, 'Backup Control Procedure', 0, 2),
  (@q_id, 'Business Compliance Policy', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz94_id, 'What is a DRP?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Data Routing Protocol', 0, 0),
  (@q_id, 'Disaster Recovery Plan — procedures to recover from a catastrophic failure', 1, 1),
  (@q_id, 'Data Retention Policy', 0, 2),
  (@q_id, 'Daily Routine Procedures', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz94_id, 'What is data classification?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Sorting data alphabetically', 0, 0),
  (@q_id, 'Categorizing data by sensitivity to apply appropriate security controls', 1, 1),
  (@q_id, 'A type of encryption', 0, 2),
  (@q_id, 'A backup strategy', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz94_id, 'What is the principle of least privilege?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Giving all users admin rights', 0, 0),
  (@q_id, 'Users get only the minimum access rights needed to do their job', 1, 1),
  (@q_id, 'A type of firewall rule', 0, 2),
  (@q_id, 'An encryption standard', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz94_id, 'What is separation of duties?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Working alone', 0, 0),
  (@q_id, 'Dividing tasks between multiple people to prevent fraud or errors', 1, 1),
  (@q_id, 'A type of access control', 0, 2),
  (@q_id, 'A backup strategy', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz94_id, 'What is security awareness training?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Technical security controls', 0, 0),
  (@q_id, 'Educating employees about security threats and best practices', 1, 1),
  (@q_id, 'A type of firewall', 0, 2),
  (@q_id, 'A penetration test', 0, 3);

-- End Quiz 94: Information Security Management

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Web Performance Optimization', 'Techniques for improving web performance', 'Web Development', 30, 75.00);
SET @quiz95_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz95_id, 'What is page load time?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Server uptime', 0, 0),
  (@q_id, 'The time it takes for a web page to fully display to a user', 1, 1),
  (@q_id, 'A type of caching', 0, 2),
  (@q_id, 'A server metric', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz95_id, 'What is minification?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Making images smaller', 0, 0),
  (@q_id, 'Removing unnecessary characters from code to reduce file size', 1, 1),
  (@q_id, 'A type of CDN', 0, 2),
  (@q_id, 'A compression format', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz95_id, 'What is lazy loading?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Loading all resources at once', 0, 0),
  (@q_id, 'Loading resources only when needed (e.g., images when scrolled into view)', 1, 1),
  (@q_id, 'A type of caching', 0, 2),
  (@q_id, 'A CDN feature', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz95_id, 'What is browser caching?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A server cache', 0, 0),
  (@q_id, 'Storing web resources in the user\'s browser to speed up repeat visits', 1, 1),
  (@q_id, 'A type of CDN', 0, 2),
  (@q_id, 'A database cache', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz95_id, 'What is gzip compression?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Image compression', 0, 0),
  (@q_id, 'Compressing web files before sending them to reduce transfer size', 1, 1),
  (@q_id, 'A JavaScript technique', 0, 2),
  (@q_id, 'A CSS optimization', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz95_id, 'What does \'render-blocking resource\' mean?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A fast-loading resource', 0, 0),
  (@q_id, 'A resource that prevents page rendering until it finishes loading', 1, 1),
  (@q_id, 'A type of cache', 0, 2),
  (@q_id, 'A CDN asset', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz95_id, 'What is a critical rendering path?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A server route', 0, 0),
  (@q_id, 'The steps a browser takes to render a page from HTML to pixels', 1, 1),
  (@q_id, 'A type of CDN', 0, 2),
  (@q_id, 'A caching strategy', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz95_id, 'What is image optimization in web performance?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Using high-resolution images always', 0, 0),
  (@q_id, 'Reducing image file size without significant quality loss', 1, 1),
  (@q_id, 'A type of minification', 0, 2),
  (@q_id, 'A caching technique', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz95_id, 'What does Lighthouse measure?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Server uptime', 0, 0),
  (@q_id, 'Web performance, accessibility, SEO, and best practices', 1, 1),
  (@q_id, 'Database speed', 0, 2),
  (@q_id, 'Network bandwidth', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz95_id, 'What is HTTP/2\'s advantage over HTTP/1.1?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Less security', 0, 0),
  (@q_id, 'Multiplexing — sending multiple requests over one connection simultaneously', 1, 1),
  (@q_id, 'Simpler protocol', 0, 2),
  (@q_id, 'Higher latency', 0, 3);

-- End Quiz 95: Web Performance Optimization

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Agile Product Management', 'Product management in Agile environments', 'Software Engineering', 30, 75.00);
SET @quiz96_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz96_id, 'Who is the Product Owner in Scrum?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'The Scrum Master', 0, 0),
  (@q_id, 'The person responsible for the product backlog and product value', 1, 1),
  (@q_id, 'The lead developer', 0, 2),
  (@q_id, 'The QA engineer', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz96_id, 'What is a product roadmap?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A sprint plan', 0, 0),
  (@q_id, 'A high-level visual plan showing the product\'s direction over time', 1, 1),
  (@q_id, 'A backlog', 0, 2),
  (@q_id, 'A test plan', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz96_id, 'What is a release plan in Agile?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A deployment script', 0, 0),
  (@q_id, 'A plan mapping backlog items to sprints for upcoming releases', 1, 1),
  (@q_id, 'A daily standup', 0, 2),
  (@q_id, 'A retrospective', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz96_id, 'What is story point estimation?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Hours of work', 0, 0),
  (@q_id, 'A relative measure of effort and complexity of a user story', 1, 1),
  (@q_id, 'Exact time estimate', 0, 2),
  (@q_id, 'A type of test', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz96_id, 'What is definition of done (DoD)?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A task is assigned', 0, 0),
  (@q_id, 'A shared checklist of conditions a user story must meet to be complete', 1, 1),
  (@q_id, 'A sprint goal', 0, 2),
  (@q_id, 'A product vision', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz96_id, 'What is a product vision?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A sprint goal', 0, 0),
  (@q_id, 'A high-level description of what the product aims to achieve', 1, 1),
  (@q_id, 'A backlog item', 0, 2),
  (@q_id, 'A sprint plan', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz96_id, 'What is feature prioritization?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Doing all features equally', 0, 0),
  (@q_id, 'Ranking features by value, effort, and strategic importance', 1, 1),
  (@q_id, 'A type of backlog', 0, 2),
  (@q_id, 'A sprint plan', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz96_id, 'What is an epic in Agile?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A small user story', 0, 0),
  (@q_id, 'A large body of work that can be broken down into user stories', 1, 1),
  (@q_id, 'A sprint goal', 0, 2),
  (@q_id, 'A product vision', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz96_id, 'What is OKR?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Objective and Key Result — a goal-setting framework for measurable outcomes', 1, 0),
  (@q_id, 'Old Key Requirement', 0, 1),
  (@q_id, 'Open Kanban Roadmap', 0, 2),
  (@q_id, 'Output Key Review', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz96_id, 'What is technical backlog?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A list of bugs only', 0, 0),
  (@q_id, 'Tasks addressing technical debt, infrastructure, and non-feature work', 1, 1),
  (@q_id, 'A product roadmap', 0, 2),
  (@q_id, 'A sprint plan', 0, 3);

-- End Quiz 96: Agile Product Management

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'Network Troubleshooting', 'Diagnosing and resolving network problems', 'Networking', 30, 75.00);
SET @quiz97_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz97_id, 'Which command tests connectivity to a host?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'traceroute', 0, 0),
  (@q_id, 'ping', 1, 1),
  (@q_id, 'nslookup', 0, 2),
  (@q_id, 'netstat', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz97_id, 'Which command traces the route packets take to a destination?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'ping', 0, 0),
  (@q_id, 'traceroute (tracert on Windows)', 1, 1),
  (@q_id, 'nslookup', 0, 2),
  (@q_id, 'ifconfig', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz97_id, 'What does \'nslookup\' do?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Tests connectivity', 0, 0),
  (@q_id, 'Queries DNS to resolve domain names to IP addresses', 1, 1),
  (@q_id, 'Shows routing table', 0, 2),
  (@q_id, 'Displays ARP cache', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz97_id, 'What command shows the routing table in Linux?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'netstat -a', 0, 0),
  (@q_id, 'route -n or ip route', 1, 1),
  (@q_id, 'ifconfig', 0, 2),
  (@q_id, 'ping', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz97_id, 'What does high latency indicate?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Fast network', 0, 0),
  (@q_id, 'Slow network response, possible congestion or distance', 1, 1),
  (@q_id, 'Low bandwidth', 0, 2),
  (@q_id, 'Packet loss', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz97_id, 'What is packet loss?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Data compression', 0, 0),
  (@q_id, 'When transmitted data doesn\'t reach its destination', 1, 1),
  (@q_id, 'A type of latency', 0, 2),
  (@q_id, 'A routing error', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz97_id, 'What does \'netstat\' show?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'DNS records', 0, 0),
  (@q_id, 'Active network connections and listening ports', 1, 1),
  (@q_id, 'Routing tables', 0, 2),
  (@q_id, 'ARP cache', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz97_id, 'What is MTU and why does it matter?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Maximum Transmission Unit — setting affects fragmentation and throughput', 1, 0),
  (@q_id, 'Minimum Transfer Unit', 0, 1),
  (@q_id, 'Medium Tunnel Usage', 0, 2),
  (@q_id, 'Maximum Transfer Utility', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz97_id, 'What is a network baseline?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A firewall rule', 0, 0),
  (@q_id, 'A record of normal network performance used to identify anomalies', 1, 1),
  (@q_id, 'A routing protocol', 0, 2),
  (@q_id, 'A type of DNS record', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz97_id, 'What is the purpose of SNMP?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Encrypting network traffic', 0, 0),
  (@q_id, 'Simple Network Management Protocol for monitoring network devices', 1, 1),
  (@q_id, 'Routing packets', 0, 2),
  (@q_id, 'Assigning IP addresses', 0, 3);

-- End Quiz 97: Network Troubleshooting

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Python Object-Oriented Programming', 'OOP concepts in Python', 'Python', 30, 75.00);
SET @quiz98_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz98_id, 'How do you define a class in Python?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'def MyClass:', 0, 0),
  (@q_id, 'class MyClass:', 1, 1),
  (@q_id, 'object MyClass:', 0, 2),
  (@q_id, 'type MyClass:', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz98_id, 'What is \'__init__\' in Python?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A module', 0, 0),
  (@q_id, 'The constructor method called when creating a new object', 1, 1),
  (@q_id, 'A destructor', 0, 2),
  (@q_id, 'A class method', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz98_id, 'What is \'self\' in a Python class method?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A global variable', 0, 0),
  (@q_id, 'A reference to the current instance of the class', 1, 1),
  (@q_id, 'A class variable', 0, 2),
  (@q_id, 'A module', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz98_id, 'What is inheritance in Python?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Copying code', 0, 0),
  (@q_id, 'A class acquiring attributes and methods from a parent class', 1, 1),
  (@q_id, 'A type of loop', 0, 2),
  (@q_id, 'A decorator', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz98_id, 'What does \'super()\' do in Python?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Calls the subclass', 0, 0),
  (@q_id, 'Calls the parent class method', 1, 1),
  (@q_id, 'Creates a class', 0, 2),
  (@q_id, 'Defines a method', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz98_id, 'What is method overriding in Python?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Calling a method twice', 0, 0),
  (@q_id, 'A subclass providing a new implementation for a parent class method', 1, 1),
  (@q_id, 'Creating a new method', 0, 2),
  (@q_id, 'Deleting a method', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz98_id, 'What is encapsulation in Python?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of loop', 0, 0),
  (@q_id, 'Bundling data and methods together, restricting direct access', 1, 1),
  (@q_id, 'A type of inheritance', 0, 2),
  (@q_id, 'A type of decorator', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz98_id, 'What does a double underscore prefix (__) do to an attribute?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Makes it public', 0, 0),
  (@q_id, 'Name-mangles it to enforce access restriction (private-like)', 1, 1),
  (@q_id, 'Makes it a class variable', 0, 2),
  (@q_id, 'Makes it a constant', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz98_id, 'What is a class method in Python?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A regular method', 0, 0),
  (@q_id, 'A method bound to the class, not instances, decorated with @classmethod', 1, 1),
  (@q_id, 'A static method', 0, 2),
  (@q_id, 'A property', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz98_id, 'What is a Python decorator?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of class', 0, 0),
  (@q_id, 'A function that wraps another function to add functionality', 1, 1),
  (@q_id, 'A type of variable', 0, 2),
  (@q_id, 'A module', 0, 3);

-- End Quiz 98: Python Object-Oriented Programming

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (1, 'IT Project Documentation', 'Documentation practices in IT projects', 'Software Engineering', 30, 75.00);
SET @quiz99_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz99_id, 'What is a Software Requirements Specification (SRS)?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A bug report', 0, 0),
  (@q_id, 'A document describing what a software system should do', 1, 1),
  (@q_id, 'A code comment', 0, 2),
  (@q_id, 'A test case', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz99_id, 'What is a System Design Document (SDD)?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A requirements document', 0, 0),
  (@q_id, 'A document detailing how a system will be built and its architecture', 1, 1),
  (@q_id, 'A test plan', 0, 2),
  (@q_id, 'A user manual', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz99_id, 'What is a README file?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A requirements doc', 0, 0),
  (@q_id, 'A file providing overview, installation, and usage information for a project', 1, 1),
  (@q_id, 'A source code file', 0, 2),
  (@q_id, 'A test file', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz99_id, 'What is API documentation?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Source code', 0, 0),
  (@q_id, 'A reference describing all endpoints, parameters, and responses of an API', 1, 1),
  (@q_id, 'A database schema', 0, 2),
  (@q_id, 'A user manual', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz99_id, 'What is a data flow diagram (DFD)?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A UML class diagram', 0, 0),
  (@q_id, 'A diagram showing how data moves through a system', 1, 1),
  (@q_id, 'A network diagram', 0, 2),
  (@q_id, 'A sequence diagram', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz99_id, 'What is change management documentation?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'API docs', 0, 0),
  (@q_id, 'Records tracking modifications made to a system over time', 1, 1),
  (@q_id, 'Source code', 0, 2),
  (@q_id, 'Test cases', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz99_id, 'What is a user manual?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Technical documentation for developers', 0, 0),
  (@q_id, 'Documentation guiding end users on how to use a software system', 1, 1),
  (@q_id, 'A requirements doc', 0, 2),
  (@q_id, 'An API reference', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz99_id, 'What is a test report?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A bug list', 0, 0),
  (@q_id, 'A document summarizing testing activities, results, and defects found', 1, 1),
  (@q_id, 'A requirements doc', 0, 2),
  (@q_id, 'A design document', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz99_id, 'What is version documentation?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A bug report', 0, 0),
  (@q_id, 'Records describing changes in each version or release of software', 1, 1),
  (@q_id, 'A user manual', 0, 2),
  (@q_id, 'An API doc', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz99_id, 'What is the purpose of inline code comments?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Slowing code execution', 0, 0),
  (@q_id, 'Explaining what specific code does for future developers', 1, 1),
  (@q_id, 'Replacing documentation', 0, 2),
  (@q_id, 'Running tests', 0, 3);

-- End Quiz 99: IT Project Documentation

INSERT INTO quizzes (teacher_id, title, description, subject, time_limit, passing_score)
VALUES (2, 'Emerging Tech: Edge AI and MLOps', 'Edge AI deployment and ML operations', 'AI/ML', 30, 75.00);
SET @quiz100_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz100_id, 'What is MLOps?', 'multiple_choice', 1, 0);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of AI model', 0, 0),
  (@q_id, 'Practices combining ML development and IT operations for production ML systems', 1, 1),
  (@q_id, 'A cloud service', 0, 2),
  (@q_id, 'A programming framework', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz100_id, 'What is model drift?', 'multiple_choice', 1, 1);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A training error', 0, 0),
  (@q_id, 'When a deployed model\'s performance degrades due to changing data patterns', 1, 1),
  (@q_id, 'A type of overfitting', 0, 2),
  (@q_id, 'A hyperparameter', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz100_id, 'What is a feature store?', 'multiple_choice', 1, 2);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of database', 0, 0),
  (@q_id, 'A centralized repository for storing and serving ML features', 1, 1),
  (@q_id, 'A model registry', 0, 2),
  (@q_id, 'A training environment', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz100_id, 'What is model versioning?', 'multiple_choice', 1, 3);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of Git', 0, 0),
  (@q_id, 'Tracking different iterations of ML models for reproducibility', 1, 1),
  (@q_id, 'A training method', 0, 2),
  (@q_id, 'A feature engineering step', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz100_id, 'What is Edge AI?', 'multiple_choice', 1, 4);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Cloud-based AI', 0, 0),
  (@q_id, 'Running AI inference directly on edge devices without cloud dependency', 1, 1),
  (@q_id, 'A type of GPU', 0, 2),
  (@q_id, 'A networking protocol', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz100_id, 'What is model quantization?', 'multiple_choice', 1, 5);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Increasing model size', 0, 0),
  (@q_id, 'Reducing model size and computation by lowering numerical precision', 1, 1),
  (@q_id, 'A training technique', 0, 2),
  (@q_id, 'A type of regularization', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz100_id, 'What is a confusion matrix?', 'multiple_choice', 1, 6);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A type of neural network', 0, 0),
  (@q_id, 'A table showing correct and incorrect predictions for a classifier', 1, 1),
  (@q_id, 'A loss function', 0, 2),
  (@q_id, 'A type of layer', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz100_id, 'What is AutoML?', 'multiple_choice', 1, 7);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Manual machine learning', 0, 0),
  (@q_id, 'Tools automating the process of selecting and tuning ML models', 1, 1),
  (@q_id, 'A type of neural network', 0, 2),
  (@q_id, 'A feature store', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz100_id, 'What is a model registry?', 'multiple_choice', 1, 8);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'A dataset store', 0, 0),
  (@q_id, 'A centralized place to store, version, and manage ML models', 1, 1),
  (@q_id, 'A feature store', 0, 2),
  (@q_id, 'A training pipeline', 0, 3);

INSERT INTO questions (quiz_id, question_text, type, points, order_index)
VALUES (@quiz100_id, 'What is A/B testing in ML?', 'multiple_choice', 1, 9);
SET @q_id = LAST_INSERT_ID();
INSERT INTO choices (question_id, choice_text, is_correct, order_index) VALUES
  (@q_id, 'Testing code quality', 0, 0),
  (@q_id, 'Comparing two model versions on live traffic to measure performance', 1, 1),
  (@q_id, 'A training technique', 0, 2),
  (@q_id, 'A type of validation', 0, 3);

-- End Quiz 100: Emerging Tech: Edge AI and MLOps

-- ============================================================
-- Seed complete: 100 students, 100 quizzes, 1000 questions
-- ============================================================
