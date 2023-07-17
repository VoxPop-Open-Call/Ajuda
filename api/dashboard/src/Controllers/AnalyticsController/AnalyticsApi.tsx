import config from "../../config";
import axiosInstance from "../AxiosInterceptor";

export interface TasksMetricsProps {
  totalTasks: number;
  totalPendingTasks: number;
  totalCompletedTasks: number;
  taskTypeGroups: Record<string, number>;
  averagePerDay: number;
  averagePerWeek: number;
  averagePerMonth: number;
  ratingBreakdown: RatingBreakdownProps;
}

export interface AgeGroupsProps {
  "age<18": number;
  "18<=age<25": number;
  "25<=age<30": number;
  "30<=age<40": number;
  "40<=age<60": number;
  "60<=age<75": number;
  "age>=75": number;
}

export interface GenderCountProps {
  m: number;
  f: number;
  x: number;
}

export interface RatingBreakdownProps {
  1: number;
  2: number;
  3: number;
  4: number;
  5: number;
}

export interface UsersMetricsProps {
  totalUsers: number;
  totalElders: number;
  totalVolunteers: number;
  totalVerifiedUsers: number;
  ageGroups: AgeGroupsProps;
  genderCount: GenderCountProps;
  languageCount: Record<string, number>;
}

export const getTasksMetrics = async (): Promise<{
  data: TasksMetricsProps;
}> => {
  const response = await axiosInstance.get(`${config.API_URL}/metrics/tasks`);
  return response;
};

export const getUsersMetrics = async (): Promise<{
  data: UsersMetricsProps;
}> => {
  const response = await axiosInstance.get(`${config.API_URL}/metrics/users`);
  return response;
};
