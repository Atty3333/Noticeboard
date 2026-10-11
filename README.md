# Noticeboard

A Java web application for campus and community notices. Users can create profiles, publish notices, and browse listings by campus, location, category, or keyword.

## Features

- Sign up, sign in, update a profile, and change a password.
- Create, edit, and delete notices with a title, description, institution, campus, location, and category.
- Publish under a username or anonymously; attach up to four images to a notice.
- Search notice titles and descriptions, and filter by campus, location, and category.
- Add profile details such as campus, location, interests, hobbies, and a profile picture.
- Notices are assigned a two-day expiry date.

Categories and campus/location choices are defined in `DataConstants.java`.

## Built with

- Java 23
- Jakarta Servlet 6.1 and JSP
- Maven WAR packaging

## Build and run

Install JDK 23 and a Jakarta Servlet 6.1-compatible container such as Tomcat 11. From the repository root:

```bash
./mvnw clean package
```

Deploy `target/Noticeboard-1.0-SNAPSHOT.war` to the servlet container. The application opens at the deployed context path, for example `http://localhost:8080/Noticeboard-1.0-SNAPSHOT/`.

On Windows, use `mvnw.cmd clean package`.

## Storage and security notes

This repository currently uses static in-memory lists for users and notices; it has no database. App data is lost when the server process restarts. Demo user records are hard-coded in `UserDirectory`, and passwords are stored and compared as plain text. Uploaded images are written under the deployed web application directory. Treat this as a learning/demo project, not a production-ready account or storage system.