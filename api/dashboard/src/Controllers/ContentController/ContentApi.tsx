import { ColumnFilterValue } from "@coreui/react-pro/src/components/smart-table/types";

import config from "../../config";
import axiosInstance from "../AxiosInterceptor";

export interface ContentProps {
  id: string;
  subject: string;
  title: string;
  subtitle: string;
  articleUrl: string;
  date: string;
  time: string;
  imageUrl: string;
  description: string;
  language: { code: string; name: string; nativeName: string };
  languageCode: string;
  period: string;
  type: string;
  state: string;
  createdAt: Date;
  updatedAt: Date;
}

export const getContentList = async (data: {
  limit: number;
  offset: number;
  orderBy: string;
  type?: string;
  filter: ColumnFilterValue;
}): Promise<{ data: ContentProps[] }> => {
  if (data.orderBy.includes("0")) {
    data.orderBy = "id asc";
  }
  const response = await axiosInstance.get(`${config.API_URL}/external`, {
    params: {
      limit: data.limit,
      offset: data.offset,
      orderBy: data.orderBy,
      type: data.type,
      ...data.filter,
    },
  });
  return response;
};

export const acceptContent = async (
  data: ContentProps
): Promise<{ data: ContentProps }> => {
  const response = await axiosInstance.put(
    `${config.API_URL}/external/${data.id}/approve`
  );
  return response;
};

export const rejectContent = async (
  data: ContentProps
): Promise<{ data: ContentProps }> => {
  const response = await axiosInstance.put(
    `${config.API_URL}/external/${data.id}/reject`
  );
  return response;
};
