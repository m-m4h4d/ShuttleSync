import { fireEvent, render, screen } from '@testing-library/react';
import App from './App';

const stops = [
  { id: 1, name: 'Retro Cafe', offset: '00:01:30' },
  { id: 10, name: 'SMME/SNS', offset: '00:15:00' },
];

const arrivals = {
  stop: stops[1],
  campus_time: '12:34:56',
  arrivals: [
    { shuttle_id: 105, start_time: '09:06:00', available: true, arrival_time: '12:36:00', seconds_until: 64 },
    { shuttle_id: 102, start_time: '09:01:30', available: true, arrival_time: null, seconds_until: null },
    { shuttle_id: 103, start_time: '09:03:00', available: false, arrival_time: '12:48:00', seconds_until: 784 },
  ],
};

beforeEach(() => {
  global.fetch = jest.fn((url) =>
    Promise.resolve({
      ok: true,
      json: () => Promise.resolve(url.endsWith('/api/stops') ? stops : arrivals),
    })
  );
});

afterEach(() => {
  delete global.fetch;
});

test('loads stops from the API and shows arrivals for the selected stop', async () => {
  render(<App />);

  expect(await screen.findByRole('option', { name: 'SMME/SNS' })).toBeInTheDocument();

  fireEvent.change(screen.getByLabelText('Stop'), { target: { value: '10' } });

  expect(await screen.findByText('12:36:00')).toBeInTheDocument();
  expect(screen.getByText('1m 4s')).toBeInTheDocument();
  expect(screen.getByText('No more today')).toBeInTheDocument();
  expect(screen.getByText('Out of service')).toBeInTheDocument();
  expect(global.fetch).toHaveBeenCalledWith(expect.stringContaining('/api/stops/10/arrivals'));
});
