DELETE FROM user WHERE email = 'test.user@atos.net';
INSERT INTO user(EMAIL, FORENAME, SURNAME, PASSWORD, JOB_TITLE, BASE_SITE, PHONE, ACTIVATION_DATE, FAILED_LOGIN_COUNT, LAST_ACCESS, ROLE) VALUES ('test.user@atos.net', 'Test', 'User', '$2a$10$dCr0X7GSMtGu8ygTi1iSO.ulFa1EosaEYy45XlutdctXxJRh.OvmS', NULL, NULL, NULL, DATE '2016-05-17', 0, TIMESTAMP '2016-05-17 09:14:00.669', 'USER');