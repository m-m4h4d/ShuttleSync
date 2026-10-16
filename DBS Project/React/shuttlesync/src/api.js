const API_URL = (process.env.REACT_APP_API_URL || 'http://127.0.0.1:8000').replace(/\/+$/, '');

async function get(path) {
  const response = await fetch(`${API_URL}${path}`);
  if (!response.ok) {
    throw new Error(`Request to ${path} failed with status ${response.status}`);
  }
  return response.json();
}

export const getStops = () => get('/api/stops');

export const getArrivals = (stopId) => get(`/api/stops/${stopId}/arrivals`);
