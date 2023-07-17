import React from "react";

import { UserProps } from "../../Controllers/UserControllers/UsersApi";
import { renderRatingStars } from "../../utils/commonUtils";

export const returnVolunteerName = (volunteer?: UserProps): string => {
  if (!volunteer) {
    return "";
  }
  return volunteer?.name;
};

export const sortingAssigmentListByDate = (
  assignment: Array<{
    comment: string;
    createdAt: Date;
    id: string;
    rating: number;
    state: string;
    task: string;
    taskId: string;
    updatedAt: Date;
    userId: string;
  }>
): Array<{
  comment: string;
  createdAt: Date;
  id: string;
  rating: number;
  state: string;
  task: string;
  taskId: string;
  updatedAt: Date;
  userId: string;
}> =>
  assignment.sort(
    (volunteerA, volunteerB) => +volunteerB.createdAt - +volunteerA.createdAt
  );

export const returnRequestRating = (
  assigmentList: Array<{
    comment: string;
    createdAt: Date;
    id: string;
    rating: number;
    state: string;
    task: string;
    taskId: string;
    updatedAt: Date;
    userId: string;
  }>
): JSX.Element => {
  if (assigmentList?.length) {
    const sortedAssigment = sortingAssigmentListByDate(assigmentList);
    const assigmentRating = sortedAssigment[0].rating;
    return <div>{renderRatingStars(assigmentRating)}</div>;
  }
  return <div>{renderRatingStars(0)}</div>;
};
