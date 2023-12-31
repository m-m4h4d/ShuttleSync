// App.js

import React from 'react';
import './App.css';
import faviconImage from './faviconImage/apple-touch-icon.png';
import moment from 'moment';
import { useState } from 'react';
import { useEffect } from 'react';
import axios from 'axios';





function App() {
  // const shuttleData = [
  //   {  shuttleId: 101, startTime: '10:00 AM', stopTime: '10:30 AM' },
  //   { shuttleId: 102, startTime: '11:00 AM', stopTime: '11:30 AM' },
  //   {  shuttleId: 103, startTime: '12:00 PM', stopTime: '12:30 PM' },
  //   {  shuttleId: 103, startTime: '12:00 PM', stopTime: '12:30 PM' },
  //   { shuttleId: 103, startTime: '12:00 PM', stopTime: '12:30 PM' },
  //   {  shuttleId: 103, startTime: '12:00 PM', stopTime: '12:30 PM' },
  //   {  shuttleId: 103, startTime: '12:00 PM', stopTime: '12:30 PM' },
  // ];

  const [data, setData] = useState([]);
  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get('http://localhost:8000/api/data');
        setData(response.data);
      } catch (error) {
        console.error('Error fetching data:', error);
      }
    };

    fetchData();
  }, []);





  const [currentTime, setCurrentTime] = useState(moment().format('HH:mm:ss'));

  useEffect(() => {
    const intervalId = setInterval(() => {
      setCurrentTime(moment().format('HH:mm:ss'));
    }, 1000);

    return () => clearInterval(intervalId);
  }, []);
  const [selectedStop, setSelectedStop] = useState('');
  const stopNames = ['SMME/SNS', 'Retro', 'Gate 4', 'Concordia 2', 'Main Office', 'Girls Hostel', 'Concordia 1', 'HBL', 'Stop 9', 'Stop 10'];



  return (
    <><nav className="navbar">
      <ul>
        <li><a href="/">Home</a></li>
        <li><a href="/about">About Us</a></li>
      </ul>
    </nav>
    <div className="app-container">
    <div className="me">

        <h1

          className="heading">

          <img src={faviconImage} alt="Favicon" className="favicon" />

          ShuttleSync


        </h1>


        <p className="welcome-message">Welcome to the Shuttle Service!</p>
        </div>
        <div className="digital-clock">{currentTime}</div>
        <select className='dropdown' value={selectedStop} onChange={(e) => setSelectedStop(e.target.value)}>
          <option value="">Select a Stop</option>
          {stopNames.map((stop, index) => (
            <option key={index} value={stop}>
              {stop}
            </option>
          ))}
        </select>




        <table className="shuttle-table">
          <thead>
            <tr>
              <th>Shuttle ID</th>
              <th>Start Time</th>
              <th>Remaining Time</th>
            </tr>
          </thead>
          <tbody>
            {data.map((shuttle, index) => (
              <tr key={index}>
                <td>{shuttle.shuttleId}</td>
                <td>{shuttle.startTime}</td>
                <td>{shuttle.stopTime}</td>
              </tr>
            ))}
          </tbody>
        </table>
        <button className='refreshbutton'>Refresh Shuttle Status here</button>
      </div></>
  );
}

export default App;
