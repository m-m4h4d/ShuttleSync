// App.js

import React, { useCallback, useEffect, useState } from 'react';
import './App.css';
import faviconImage from './faviconImage/apple-touch-icon.png';
import { getArrivals, getStops } from './api';

const AUTO_REFRESH_MS = 30000;
const CAMPUS_TIMEZONE = process.env.REACT_APP_CAMPUS_TIMEZONE || 'Asia/Karachi';

function formatClock(date) {
  return date.toLocaleTimeString('en-GB', { hour12: false, timeZone: CAMPUS_TIMEZONE });
}

function formatRemaining(seconds) {
  if (seconds === null || seconds === undefined) {
    return 'No more today';
  }
  if (seconds <= 0) {
    return 'Arriving now';
  }
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const rest = seconds % 60;
  if (hours > 0) {
    return `${hours}h ${minutes}m`;
  }
  return minutes > 0 ? `${minutes}m ${rest}s` : `${rest}s`;
}

function App() {
  const [now, setNow] = useState(() => new Date());
  const [stops, setStops] = useState([]);
  const [selectedStop, setSelectedStop] = useState('');
  const [arrivals, setArrivals] = useState([]);
  const [fetchedAt, setFetchedAt] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    const intervalId = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(intervalId);
  }, []);

  useEffect(() => {
    getStops()
      .then(setStops)
      .catch((err) => {
        console.error('Error fetching stops:', err);
        setError('Could not load stops. Is the API running?');
      });
  }, []);

  const refresh = useCallback(async () => {
    if (!selectedStop) {
      return;
    }
    setLoading(true);
    try {
      const data = await getArrivals(selectedStop);
      setArrivals(data.arrivals);
      setFetchedAt(Date.now());
      setError('');
    } catch (err) {
      console.error('Error fetching arrivals:', err);
      setError('Could not load shuttle times. Please try again.');
    } finally {
      setLoading(false);
    }
  }, [selectedStop]);

  useEffect(() => {
    setArrivals([]);
    setFetchedAt(null);
    if (!selectedStop) {
      return undefined;
    }
    refresh();
    const intervalId = setInterval(refresh, AUTO_REFRESH_MS);
    return () => clearInterval(intervalId);
  }, [selectedStop, refresh]);

  // Count down locally between refreshes from the server's SecondsUntil.
  const elapsed = fetchedAt ? Math.max(0, Math.floor((now.getTime() - fetchedAt) / 1000)) : 0;

  return (
    <>
      <nav className="navbar">
        <ul>
          <li><a href="/">Home</a></li>
        </ul>
      </nav>
      <div className="app-container">
        <div className="me">
          <h1 className="heading">
            <img src={faviconImage} alt="Favicon" className="favicon" />
            ShuttleSync
          </h1>
          <p className="welcome-message">Welcome to the Shuttle Service!</p>
        </div>
        <div className="digital-clock">{formatClock(now)}</div>
        <select
          className="dropdown"
          aria-label="Stop"
          value={selectedStop}
          onChange={(e) => setSelectedStop(e.target.value)}
        >
          <option value="">Select a Stop</option>
          {stops.map((stop) => (
            <option key={stop.id} value={stop.id}>
              {stop.name}
            </option>
          ))}
        </select>

        {error && <p className="status-message error">{error}</p>}

        {selectedStop && (
          <table className="shuttle-table">
            <thead>
              <tr>
                <th>Shuttle ID</th>
                <th>Next Arrival</th>
                <th>Remaining Time</th>
              </tr>
            </thead>
            <tbody>
              {arrivals.map((shuttle) => (
                <tr key={shuttle.shuttle_id} className={shuttle.available ? '' : 'unavailable'}>
                  <td>{shuttle.shuttle_id}</td>
                  <td>{shuttle.arrival_time || '—'}</td>
                  <td>
                    {shuttle.available
                      ? formatRemaining(
                          shuttle.seconds_until === null ? null : shuttle.seconds_until - elapsed
                        )
                      : 'Out of service'}
                  </td>
                </tr>
              ))}
              {!loading && arrivals.length === 0 && !error && (
                <tr>
                  <td colSpan={3}>No shuttles serve this stop.</td>
                </tr>
              )}
            </tbody>
          </table>
        )}

        <button className="refreshbutton" onClick={refresh} disabled={!selectedStop || loading}>
          {loading ? 'Refreshing…' : 'Refresh Shuttle Status here'}
        </button>
      </div>
    </>
  );
}

export default App;
