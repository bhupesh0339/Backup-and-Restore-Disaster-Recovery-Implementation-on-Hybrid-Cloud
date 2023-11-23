const express = require('express');
const mysql = require('mysql');
const cron = require('node-cron');
const dotenv = require('dotenv');
dotenv.config();
const app = express();
const port = process.env.PORT || 3000;
const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
});
db.connect((err) => {
  if (err) {
    console.error('Error connecting to MySQL database:', err);
    return;
  }
  console.log('Connected to MySQL database');
});
const createTableQuery = `
  CREATE TABLE IF NOT EXISTS time_entries (
    id TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    timestamp DATETIME,
    PRIMARY KEY (id)
  )
`;
db.query(createTableQuery, (err) => {
  if (err) {
    console.error('Error creating table:', err);
  }
});
cron.schedule('* * * * *', () => {
  const insertQuery = 'INSERT INTO time_entries (timestamp) VALUES (NOW())';
  db.query(insertQuery, (err, results) => {
    if (err) {
      console.error('Error inserting data:', err);
    }
  });
});
app.get('/', (req, res) => {
  const selectQuery = 'SELECT * FROM time_entries ORDER BY timestamp DESC';
  db.query(selectQuery, (err, results) => {
    if (err) {
      console.error('Error fetching entries:', err);
      res.status(500).json({ error: 'Internal Server Error' });
      return;
    }
    const entries = results.map((entry) => ({
      id: entry.timestamp, // Use timestamp as id
      timestamp: entry.timestamp,
    }));

    res.json(entries);
  });
});
app.use(express.static('public'));
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});