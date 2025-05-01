USE [FootballStats];
GO

-- Check if tables exist before creating them
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Stadiums' AND schema_id = SCHEMA_ID('Football'))
BEGIN
    -- Create Stadiums table
    CREATE TABLE Football.Stadiums (
        StadiumID INT IDENTITY(1,1) PRIMARY KEY,
        StadiumName NVARCHAR(100) NOT NULL,
        City NVARCHAR(50) NOT NULL,
        State NVARCHAR(2) NOT NULL,
        Capacity INT,
        SurfaceType NVARCHAR(50),
        YearBuilt INT
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Teams' AND schema_id = SCHEMA_ID('Football'))
BEGIN
    -- Create Teams table with all coordinator fields
    CREATE TABLE Football.Teams (
        TeamID INT IDENTITY(1,1) PRIMARY KEY,
        TeamName NVARCHAR(50) NOT NULL,
        City NVARCHAR(50),
        StadiumID INT FOREIGN KEY REFERENCES Football.Stadiums(StadiumID),
        FoundedYear INT,
        HeadCoachPersonID INT,
        OffensiveCoordinatorPersonID INT,
        DefensiveCoordinatorPersonID INT,
        Division NVARCHAR(50),
        Conference NVARCHAR(50)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Games' AND schema_id = SCHEMA_ID('Football'))
BEGIN
    -- Create Games table
    CREATE TABLE Football.Games (
        GameID INT IDENTITY(1,1) PRIMARY KEY,
        HomeTeamID INT NOT NULL FOREIGN KEY REFERENCES Football.Teams(TeamID),
        AwayTeamID INT NOT NULL FOREIGN KEY REFERENCES Football.Teams(TeamID),
        StadiumID INT NOT NULL FOREIGN KEY REFERENCES Football.Stadiums(StadiumID),
        GameDateTime DATETIME2 NOT NULL,
        HomeTeamScore INT NOT NULL,
        AwayTeamScore INT NOT NULL,
        Attendance INT,
        Winner INT FOREIGN KEY REFERENCES Football.Teams(TeamID),
        GameStatus NVARCHAR(20),
        Field NVARCHAR(50)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Players' AND schema_id = SCHEMA_ID('Football'))
BEGIN
    -- Create Players table with exact fields from image
    CREATE TABLE Football.Players (
        PlayerID INT IDENTITY(1,1) PRIMARY KEY,
        TeamID INT FOREIGN KEY REFERENCES Football.Teams(TeamID),
        FirstName NVARCHAR(50) NOT NULL,
        LastName NVARCHAR(50) NOT NULL,
        JerseyNumber INT NOT NULL,
        Position NVARCHAR(10),
        Age INT,
        Height NVARCHAR(10),
        Weight INT,
        YearsOfExperience INT,
        IsInjured BIT DEFAULT 0,
        InjuryDescription NVARCHAR(255)
    );
END
GO

-- Drop and recreate the RawPlayByPlay table
IF OBJECT_ID('Football.RawPlayByPlay', 'U') IS NOT NULL
    DROP TABLE Football.RawPlayByPlay;

CREATE TABLE Football.RawPlayByPlay (
    play_id INT,
    game_id VARCHAR(20) NOT NULL,
    home_team VARCHAR(3) NOT NULL,
    away_team VARCHAR(3) NOT NULL,
    posteam VARCHAR(3),
    defteam VARCHAR(3),
    game_date DATE NOT NULL,
    total_home_score SMALLINT,
    total_away_score SMALLINT,
    passer_player_id VARCHAR(12),
    passer_player_name VARCHAR(50),
    passing_yards SMALLINT,
    receiver_player_id VARCHAR(12),
    receiver_player_name VARCHAR(50),
    receiving_yards SMALLINT,
    rusher_player_id VARCHAR(12),
    rusher_player_name VARCHAR(50),
    rushing_yards SMALLINT,
    pass_touchdown BIT,
    rush_touchdown BIT,
    complete_pass BIT,
    sack BIT,
    interception BIT,
    solo_tackle BIT,
    assist_tackle BIT,
    field_goal_attempt BIT,
    field_goal_result VARCHAR(10),
    punt_attempt BIT,
    punt_yards SMALLINT,
    stadium VARCHAR(50),
    surface VARCHAR(20),
    passer_jersey_number VARCHAR(10),
    rusher_jersey_number VARCHAR(10),
    receiver_jersey_number VARCHAR(10)
);

-- Perform BULK INSERT from a location accessible by SQL Server
BULK INSERT Football.RawPlayByPlay
FROM 'C:\Users\riley\source\repos\FootballDatabase510\play_by_play_2024.csv' -- Must be local to SQL Server, not client
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', -- CSV means comma-separated
    ROWTERMINATOR = '\n',
    TABLOCK
);
