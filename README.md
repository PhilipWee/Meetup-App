# Meetup Mouse

*An Undergraduate Research Opportunities Programme (UROP) initiated by a group of 5*

![](MeetUp_Logo-0a25f6e3-6fca-46d1-98f1-4e5de3f25612.png)

# Team

- Philip Wee 😆
- Stephen Alvin 😁
- Julia Chua 🤣
- Veda Alexandra 😉
- Joel Yang 🤗

# Problem Statement

## Empathize

There has always been a lag in deciding what place to meet up at. Be it a group outing, a date, or even business meeting, there is a constant statement that goes through all our heads when the location has been decided:

> *How far is it from here?*

## Define - Official Statement

The organizational difficulty in deciding as a group or pair, a specific location to rendezvous at for a planned activity or event. 

### Target Group

People planning for any sort of gathering event (e.g. business meeting, class outing, romantic date)

# Proposed Solution

**A location optimization app that calculates the best rendezvous point for an event while taking into account the type of meeting and each member's preferences.**

## Components

1. `Android Application`
2. `Web page`
3. `Algorithm (running on the server)`

# Android Application

## Functional Process:

### Step 1: Gather data

![](Untitled-14dc3173-0ac4-4794-8dd7-0c340ecd297f.png)

![](Untitled-d4e976fd-7ce8-4baf-95ca-15eef643b05d.png)

![](Untitled-9a75828c-de66-43b5-9092-e558df8aec55.png)

- Username & Current Location
- Meeting Type

    `Date` `Outing` `Meeting` 

- Preferences
    - Activity

        `Lunch/Dinner` `Recreation` `Study`

    - Transport

        `Driving` `Public Transit` `Walk`

    - Speed

        `Fast` `Regular` `No Preference`

    - Ratings

        `Best` `Regular` `No Preference`

### Step 2: Wait for sign-ups

Shareable link will be created after the initial details have been provided to the app by the first participant, the organizer. Anyone with the link is able to join the list of participants of the meeting

Once all participants have signed up, the organizer can tap on the button to calculate and give a list of possible locations for the meet up

![](Untitled-91b77229-5891-4a16-ba8f-e3b1f85b6277.png)

![](Untitled-7682abbb-661d-449f-a731-62ad178400eb.png)

### Step 3: Server Calculation

**Data**
Location data of all possible places is taken from Google Places API and temporarily stored on PostgreSQL.

**Algorithm**

1. For each starting person dijkstra your way to each restaurant and record all the distances

2. Sum the total time taken for all the restaurants

3. See which restaurants have the lowest total time

## Final App Demonstration!

[video_2019-10-06_17-14-30.mp4](https://drive.google.com/file/d/1wcxC6vh3JuHDaGJF92Ezm7xTWRE4-tr5/view?usp=sharing)