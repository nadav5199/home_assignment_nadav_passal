import { useState, useEffect } from 'react';
import { getEmployees } from './services/employeeService';
import { STRINGS } from './strings';
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
    return <div className="status">{STRINGS.LOADING}</div>;
  }

  if (error) {
    return <div className="error">{STRINGS.ERROR_LOAD_EMPLOYEES}{error}</div>;
  }

  return (
    <div className="container">
      <h1>{STRINGS.PAGE_TITLE}</h1>
      <table>
        <thead>
          <tr>
            <th>{STRINGS.TABLE_HEADER_EMPLOYEE}</th>
            <th>{STRINGS.TABLE_HEADER_DEPARTMENT}</th>
            <th>{STRINGS.TABLE_HEADER_TOTAL_TASKS}</th>
            <th>{STRINGS.TABLE_HEADER_PENDING}</th>
            <th>{STRINGS.TABLE_HEADER_IN_PROGRESS}</th>
            <th>{STRINGS.TABLE_HEADER_DONE}</th>
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
