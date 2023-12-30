import React, {useState, useEffect} from 'react'
import api from './api'


const App = () => {
  const [shuttle, setShuttles] = useState([]);
  const [formData, setFormData] = useState({
    shuttleid: 0,
    starttime: 0,
    isavailable: false
  });

  const fetchShuttles = async () => {
    const response = await api.get('/shuttle/');
    setShuttles(response.data)
  };

  useEffect(() => {
    fetchShuttles();
  }, []);

  const handleInputChange = (event) => {
    const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
    setFormData ({
      ...formData,
      [event.target.name]: value,
    });
  };

  const handleFormSubmit = async (event) => {
    event.preventDefault();

    await api.post('/shuttle/', formData);
    fetchShuttles();
    setFormData({
      shuttleid: 0,
      starttime: 0,
      isavailable: false
    });
  };


  return (
    <div>
      <nav className='navbar navbar-dark bg-primary'>
        <div className='container-fluid'>
          <a className='navbar-brand' href=".">
            ShuttleSync
          </a>
        </div>
      </nav>

      <div className='container'>
        <form onSubmit={handleFormSubmit}>
          <div className='mb-3 mt-3'>
            <label htmlFor='shuttleid' className='form-label'>
              ShuttleID
            </label>
            <input type='text' className='form-control' id='shuttleid' name='shuttleid' onChange={handleInputChange} value={formData.shuttleid} />
          </div>

          <div className='mb-3'>
            <label htmlFor='starttime' className='form-label'>
              StartTime
            </label>
            <input type='text' className='form-control' id='starttime' name='starttime' onChange={handleInputChange} value={formData.starttime} />
          </div>

          <div className='mb-3'>
            <label htmlFor='isavailable' className='form-label'>
              IsAvailable
            </label>
            <input type='checkbox' id='isavailable' name='isavailable' onChange={handleInputChange} value={formData.isavailable} />
          </div>

          <button type='submit' className='btn btn-primary'>
            Submit
          </button>
          
        </form>

      </div>

    </div>
  )
};

export default App;