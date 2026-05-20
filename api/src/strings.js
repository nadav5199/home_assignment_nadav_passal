module.exports = {
  ROUTE_EMPLOYEES: '/employees',
  ROUTE_TASKS: '/tasks',

  LOG_DB_CONNECTED: 'Connected to SQL Server',
  LOG_API_RUNNING: 'API running on http://localhost:',
  LOG_DB_CONNECT_FAILED: 'Failed to connect to database:',

  SP_GET_EMPLOYEE_TASK_SUMMARY: 'usp_GetEmployeeTaskSummary',
  SP_GET_ALL_TASKS: 'usp_GetAllTasks',
  SP_UPDATE_TASK_STATUS: 'usp_UpdateTaskStatus',

  PARAM_TASK_ID: 'TaskID',
  PARAM_NEW_STATUS: 'NewStatus',

  ERR_STATUS_REQUIRED: 'Request body must include a "status" field.',
  MSG_TASK_STATUS_UPDATED: 'Task status updated successfully.',
};
