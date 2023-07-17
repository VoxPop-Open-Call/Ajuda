import { ColumnFilterValue } from "@coreui/react-pro/src/components/smart-table/types";

import config from "../../config";
import axiosInstance from "../AxiosInterceptor";

export interface UserProps {
  birthday: string;
  conditions: Array<{
    code: string;
    createdAt: Date;
    id: string;
    updatedAt: Date;
  }>;
  createdAt: Date;
  elder: {
    emergencyContacts: Array<{
      name: string;
      phoneNumber: string;
    }>;
  };
  email: string;
  fontScale: number;
  gender: string;
  id: string;
  languages: Array<{
    code: string;
    name: string;
    nativeName: string;
  }>;
  location: {
    address: string;
    lat: number;
    long: number;
    radius: number;
  };
  name: string;
  phoneNumber: string;
  subject: string;
  updatedAt: Date;
  verified: boolean;
  volunteer: {
    availabilities: Array<{
      end: string;
      start: string;
      weekDay: number;
    }>;

    taskTypes: Array<{
      code: string;
      createdAt: Date;
      id: string;
      updatedAt: Date;
    }>;
  };
  image: UserImageProps;
  rating: UserRatingProps;
  reviews: Array<UserReviewsProps>;
}

export interface UserImageProps {
  url: string;
  method: string;
}

export interface UserRatingProps {
  averageRating: number;
  reviewCount: number;
}

export interface UserReviewsProps {
  comment: string;
  id: string;
  rating: number;
  task: {
    assignments: Array<{
      comment: string;
      createdAt: Date;
      id: string;
      rating: number;
      state: string;
      task: string;
      taskId: string;
      updatedAt: Date;
      userId: string;
    }>;
    createdAt: Date;
    date: string;
    description: string;
    id: string;
    requester: {
      birthday: string;
      conditions: Array<{
        code: string;
        createdAt: Date;
        id: string;
        updatedAt: Date;
      }>;

      createdAt: Date;
      elder: {
        emergencyContacts: Array<{
          name: string;
          phoneNumber: string;
        }>;
      };
      email: string;
      fontScale: number;
      gender: string;
      id: string;
      languages: Array<{
        code: string;
        name: string;
        nativeName: string;
      }>;
      name: string;
      phoneNumber: string;
      subject: string;
      updatedAt: Date;
      verified: boolean;
      volunteer: {
        availabilities: Array<{
          end: string;
          start: string;
          weekDay: number;
        }>;
        taskTypes: Array<{
          code: string;
          createdAt: Date;
          id: string;
          updatedAt: Date;
        }>;
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
  };
  taskId: string;
}

export const getUserList = async (data: {
  limit: number;
  offset: number;
  orderBy: string;
  filter: ColumnFilterValue;
}): Promise<{
  data: UserProps[];
}> => {
  if (data.orderBy.includes("0")) {
    data.orderBy = "id asc";
  }
  const response = await axiosInstance.get(`${config.API_URL}/users`, {
    params: {
      limit: data.limit,
      offset: data.offset,
      orderBy: data.orderBy,
      ...data.filter,
    },
  });
  return response;
};

export const verifyUser = async (
  data: UserProps
): Promise<{ data: UserProps }> => {
  const response = await axiosInstance.put(
    `${config.API_URL}/users/${data.id}/verify`
  );
  return response;
};

export const deleteUser = async (
  data: UserProps
): Promise<{ data: UserProps }> => {
  const response = await axiosInstance.delete(
    `${config.API_URL}/users/${data.id}`
  );
  return response;
};

export const getUserDetails = async (
  userId: string
): Promise<{ data: UserProps }> => {
  const response = await axiosInstance.get(`${config.API_URL}/users/${userId}`);
  return response;
};

export const getUserImage = async (
  userId: string
): Promise<{ data: UserImageProps }> => {
  const response = await axiosInstance.get(
    `${config.API_URL}/users/${userId}/picture-get-url`
  );
  return response;
};

export const getUserRating = async (
  userId: string
): Promise<{ data: UserRatingProps }> => {
  const response = await axiosInstance.get(
    `${config.API_URL}/users/${userId}/rating`
  );
  return response;
};

export const getUserReviews = async (
  userId: string
): Promise<{ data: UserReviewsProps[] }> => {
  const response = await axiosInstance.get(
    `${config.API_URL}/users/${userId}/reviews`
  );
  return response;
};
