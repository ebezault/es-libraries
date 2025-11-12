CREATE TABLE jwt_auth_new (
  `uid` INTEGER NOT NULL,
  `token` VARCHAR(1024) NOT NULL,
  `secret` 	TEXT NOT NULL,
  `apps` 	TEXT,
  `refresh`	TEXT NOT NULL,
  CONSTRAINT PK_uid_token_key PRIMARY KEY (uid,token(512))
);

INSERT INTO jwt_auth_new SELECT * FROM jwt_auth;
DROP TABLE jwt_auth;
ALTER TABLE jwt_auth_new RENAME TO jwt_auth;

