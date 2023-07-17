import { ColumnFilterValue } from "@coreui/react-pro/src/components/smart-table/types";

import config from "../../config";
import axiosInstance from "../AxiosInterceptor";
import { UserProps } from "../UserControllers/UsersApi";

export interface RequestProps {
  acceptedVolunteer?: UserProps;
  assignments: [
    {
      comment: string;
      createdAt: Date;
      id: string;
      rating: number;
      state: string;
      task: string;
      taskId: string;
      updatedAt: Date;
      userId: string;
    }
  ];
  canceled: boolean;
  createdAt: Date;
  date: string;
  description: string;
  id: string;
  requester: {
    birthday: string;
    conditions: [
      {
        code: string;
        createdAt: Date;
        id: string;
        updatedAt: Date;
      }
    ];
    createdAt: Date;
    elder: {
      emergencyContacts: [
        {
          name: string;
          phoneNumber: string;
        }
      ];
    };
    email: string;
    fontScale: number;
    gender: string;
    id: string;
    languages: [
      {
        code: string;
        name: string;
        nativeName: string;
      }
    ];
    name: string;
    phoneNumber: string;
    subject: string;
    updatedAt: Date;
    verified: boolean;
    volunteer: {
      availabilities: [
        {
          end: string;
          start: string;
          weekDay: number;
        }
      ];
      taskTypes: [
        {
          code: string;
          createdAt: Date;
          id: string;
          updatedAt: Date;
        }
      ];
    };
  };
  requesterId: string;
  taskType: {
    code: string;
    createdAt: Date;
    id: string;
    updatedAt: Date;
  };
  taskTypeId: string;
  timeFrom: string;
  timeTo: string;
  updatedAt: Date;
}

export const getRequestList = async (
  paginationData: {
    limit: number;
    offset: number;
    orderBy: string;
    filter: ColumnFilterValue;
  },
  taskStatusData: { isComplete: boolean; isUpcoming: boolean }
): Promise<{ data: RequestProps[] }> => {
  const params = { ...paginationData };
  if (!params.orderBy.includes("0")) {
    if (params.orderBy.includes("taskType")) {
      params.orderBy = params.orderBy.replace("taskType", "code");
    } else if (params.orderBy.includes("requester")) {
      params.orderBy = params.orderBy.replace("requester", "name");
    }
  } else {
    params.orderBy = "id asc";
  }

  const response = await axiosInstance.get(`${config.API_URL}/tasks`, {
    params: {
      limit: params.limit,
      offset: params.offset,
      orderBy: params.orderBy,
      completed: taskStatusData.isComplete,
      upcoming: taskStatusData.isUpcoming,
      ...params.filter,
    },
  });
  return response;
};
