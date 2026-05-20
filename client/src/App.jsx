import { useState, useEffect } from 'react';
import { getEmployees } from './services/employeeService';
import './App.css';

export default function App() {
  const [employees, setEmployees] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    getEmployees()
      .then(setEmployees)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return <div className="status">Loading...</div>;
  }

  if (error) {
    return <div className="error">Failed to load employees: {error}</div>;
  }

  return (
    <div className="container">
      <h1>Employee Task Summary</h1>
      <table>
        <thead>
          <tr>
            <th>Employee</th>
            <th>Department</th>
            <th>Total Tasks</th>
            <th>Pending</th>
            <th>In Progress</th>
            <th>Done</th>
          </tr>
        </thead>
        <tbody>
          {employees.map((emp) => (
            <tr key={emp.EmployeeID}>
              <td>{emp.FullName}</td>
              <td>{emp.DepartmentName}</td>
              <td>{emp.TotalTasks}</td>
              <td>{emp.PendingTasks}</td>
              <td>{emp.InProgressTasks}</td>
              <td>{emp.DoneTasks}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
