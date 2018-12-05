setwd("~/Desktop/Class/BIGDATA/Assignment/")
library("RODBC")

connection <- odbcConnect("bigdata", uid = "root", pwd = "novacancy")
sqlTables(connection)

sqlQuery(connection, "CREATE TABLE users(id int, first_name varchar(25), last_name varchar(25));")
sqlQuery(connection, "ALTER TABLE users ADD PRIMARY KEY (id);")
sqlTables(connection)

sqlQuery(connection, "Insert INTO users (id, first_name, last_name) values 
                              (1, 'Samuel', 'Mussie'),
                              (2, 'Abraham', 'Kindu'),
                              (3, 'Abdulhamid', 'Abdo');")
users <- sqlQuery(connection, "SELECT * FROM users;")
View(users)

sex <- factor(c("M","M", "M"), levels = c("M", "F"))
users <- cbind(users, sex)
sqlSave(connection, users, tablename = "users_updated", rownames = FALSE)
sqlTables(connection)

users_updated <- sqlQuery(connection, "SELECT * FROM users_updated;")
View(users_updated)

sqlQuery(connection, "CREATE TABLE addresses
						(user_id int, house_no int, city varchar(30) NOT NULL, 
         					region varchar(30) NOT NULL, PRIMARY KEY (user_id), 
         						FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE);")
sqlTables(connection)

addresses <- read.table("addresses.txt", header = TRUE, sep = ",")
View(addresses)

sqlSave(connection, addresses, rownames = FALSE, append = TRUE)
db_addresses <- sqlQuery(connection, "SELECT * FROM addresses;")
View(db_addresses)


sqlQuery(connection, "CREATE TABLE grades
						(id int, user_id int, course_name varchar(30) NOT NULL, 
         					course_grade varchar(4) NOT NULL, PRIMARY KEY (id), 
         						FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE);")
sqlTables(connection)

student_grades <- read.csv("grades.csv")

View(student_grades)

letter_grades <- vector(mode = "character", length = length(student_grades$grade))
letter_grades[student_grades$grade>=90] <-"A+"
letter_grades[student_grades$grade<90 & student_grades$grade>83] <-"A"
letter_grades[student_grades$grade>80 & student_grades$grade<=83] <-"A-"
letter_grades[student_grades$grade>=75 & student_grades$grade<=80] <-"B+"
letter_grades[student_grades$grade<75 & student_grades$grade>=68] <-"B"
letter_grades[student_grades$grade<68] <-"D"

course_grade <- factor(letter_grades, levels = c("D", "B", "B+", "A-", "A", "A+"), ordered = TRUE)

grades <- cbind(student_grades[,1:3], course_grade)
View(grades)

sqlSave(connection, grades, rownames = FALSE, append = TRUE)
db_grades <- sqlQuery(connection, "SELECT * FROM grades;")
View(db_grades)

sqlQuery(connection, "UPDATE grades SET course_grade='C' WHERE course_grade ='D';")
db_grades <- sqlQuery(connection, "SELECT * FROM grades;")
summary(db_grades)
View(db_grades)

sqlQuery(connection, "DELETE FROM users WHERE id=1;")
users <- sqlQuery(connection, "SELECT * FROM users;")
View(users)

db_addresses <- sqlQuery(connection, "SELECT * FROM addresses;")
summary(db_addresses)
View(db_addresses)

db_grades <- sqlQuery(connection, "SELECT * FROM grades;")
summary(db_grades)
View(db_grades)




