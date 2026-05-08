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

INSERT INTO users (name, email, password_hash, role) VALUES
('Admin Teacher', 'admin@scan2quiz.com',
'$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
'admin'),
('Ms. Reyes', 'reyes@scan2quiz.com',
'$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
'teacher');

INSERT INTO students (student_id, name, section, year_level, barcode)
VALUES
('2024-00001', 'Juan dela Cruz',  'BSCS 3-A', 3, 'BC2024001'),
('2024-00002', 'Maria Santos',    'BSCS 3-A', 3, 'BC2024002'),
('2024-00003', 'Pedro Reyes',     'BSCS 3-B', 3, 'BC2024003'),
('2024-00004', 'Ana Gonzales',    'BSIT 2-A', 2, 'BC2024004'),
('2024-00005', 'Carlo Mendoza',   'BSIT 2-A', 2, 'BC2024005');