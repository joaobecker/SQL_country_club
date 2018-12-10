/* In this project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT	name
FROM country_club.Facilities
WHERE membercost > 0


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(name) 
FROM country_club.Facilities
WHERE membercost =0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT	facid,
		name,
		membercost,
		monthlymaintenance
FROM country_club.Facilities
WHERE membercost < (20 * monthlymaintenance) / 100

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM country_club.Facilities
WHERE facid IN (1, 5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT	name,
		monthlymaintenance,
		CASE WHEN monthlymaintenance > 100 THEN 'expensive' ELSE 'cheap' END AS maintenanceprice
FROM country_club.Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT 	table_1.firstname,
		table_1.surname
FROM country_club.Members table_1
JOIN (
		SELECT MAX(joindate) AS last_signedup
		FROM country_club.Members
	) table_2
ON table_1.joindate = table_2.last_signedup


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
-- all members who have used a tennis court? 
-- name of the court, and the name of the member || single column

SELECT DISTINCT CONCAT(booking.name, ' - ', member.firstname, ' ', member.surname) AS fac_memb_name
FROM (
		SELECT firstname, surname, memid 
		FROM country_club.Members
	) member
JOIN (
	SELECT court.name, book.bookid, book.memid, book.facid
	FROM country_club.Bookings book
	JOIN (
	    SELECT facid, name 
	    FROM country_club.Facilities
	    WHERE name IN ('Tennis Court 1', 'Tennis Court 2')
		) court
	ON book.facid = court.facid
	) booking
ON member.memid = booking.memid
ORDER BY member.firstname, booking.name


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
-- name of the facility   -> country_club.Facilities -> name
-- name of the member formatted as a single column -> country_club.Members -> firstname, surname
-- booking date -> country_club.Bookings -> 
-- cost -> country_club.Facilities -> membercost, guestcost

SELECT 	fac.name,
		CONCAT(member.firstname, ' ',member.surname) AS member_name,
		CASE WHEN booking.memid = 0 THEN booking.slots * fac.guestcost ELSE booking.slots * fac.membercost END AS totalcost
FROM country_club.Members member
JOIN country_club.Bookings booking
	ON member.memid = booking.memid
JOIN country_club.Facilities fac
	ON booking.facid = fac.facid
WHERE CASE WHEN booking.memid = 0 THEN booking.slots * fac.guestcost > 30 ELSE booking.slots * fac.membercost > 30 END AND LEFT( booking.starttime, 10 ) = '2012-09-14'
ORDER BY 3 DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT	sub.name,
		CONCAT(member.firstname, ' ',member.surname) AS member_name,
		sub.totalcost AS total_cost		
FROM country_club.Members member
JOIN (
	SELECT 	fac.name, 
			CASE WHEN booking.memid = 0 THEN booking.slots * fac.guestcost ELSE booking.slots * fac.membercost END AS totalcost,
			booking.memid,
			booking.starttime
	FROM country_club.Bookings booking
	JOIN country_club.Facilities fac
		ON booking.facid = fac.facid
	) sub
ON member.memid = sub.memid
WHERE sub.totalcost > 30 AND LEFT( sub.starttime, 10 ) = '2012-09-14'
ORDER BY 3 DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT *
FROM (
	SELECT 	fac.name,
			SUM(CASE WHEN booking.memid = 0 THEN booking.slots * fac.guestcost ELSE booking.slots * fac.membercost END) AS totalcost
	FROM country_club.Facilities fac		
	JOIN country_club.Bookings booking
	ON fac.facid = booking.facid
	GROUP BY 1
	) sub
WHERE sub.totalcost < 1000



