CREATE TABLE api_key_auth(
  `uid` INTEGER NOT NULL,
  `name` VARCHAR(255),
  `key_id` VARCHAR(255) NOT NULL,
  `key_hash` VARCHAR(255) NOT NULL,
  `created_at` DATETIME NOT NULL,
  `used_at` DATETIME,
  `expires_at` DATETIME,
  `status` VARCHAR(32), /* active, revoked, inactive, expired */
  `scopes` 	TEXT,
  `data`	TEXT, /* Description, last used IPs, allowed_ips, rate_limit requests per hour,  ... */
  CONSTRAINT PK_uid_token_key PRIMARY KEY (uid,key_id)
);
