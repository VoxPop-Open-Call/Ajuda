import { ColumnFilterValue } from "@coreui/react-pro/src/components/smart-table/types";

import config from "../../config";
import axiosInstance from "../AxiosInterceptor";
import {
  UserImageProps,
  UserProps,
  UserRatingProps,
  UserReviewsProps,
} from "../UserControllers/UsersApi";

export const getVolunteerList = async ({
  limit,
  offset,
  orderBy,
  filter,
}: {
  limit: number;
  offset: number;
  orderBy: string;
  filter: ColumnFilterValue;
}): Promise<{ data: UserProps[] }> => {
  if (orderBy.includes("0")) {
    orderBy = "id asc";
  }
  const response = await axiosInstance.get(`${config.API_URL}/users`, {
    params: {
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      volunteers: true,
      ...filter,
    },
  });
  return response;
};

export const getVolunteerDetails = async (
  userId: string
): Promise<{ data: UserProps }> => {
  const response = await axiosInstance.get(`${config.API_URL}/users/${userId}`);
  return response;
};

export const getVolunteerImage = async (
  userId: string
): Promise<{ data: UserImageProps }> => {
  const response = await axiosInstance.get(
    `${config.API_URL}/users/${userId}/picture-get-url`
  );
  return response;
};

export const getVolunteerRating = async (
  userId: string
): Promise<{ data: UserRatingProps }> => {
  const response = await axiosInstance.get(
    `${config.API_URL}/users/${userId}/rating`
  );
  return response;
};

export const getVolunteerReviews = async (
  userId: string
): Promise<{ data: UserReviewsProps[] }> => {
  const response = await axiosInstance.get(
    `${config.API_URL}/users/${userId}/reviews`
  );
  return response;
};
