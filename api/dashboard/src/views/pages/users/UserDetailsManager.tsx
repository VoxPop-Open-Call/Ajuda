import React, { useCallback, useMemo, useState } from "react";

import { useParams } from "react-router";

import {
  UserProps,
  getUserDetails,
  getUserImage,
  getUserRating,
  getUserReviews,
} from "../../../Controllers/UserControllers/UsersApi";

import UserDetails from "./UserDetails";

const UserDetailsManager: React.FC = (): JSX.Element => {
  const params = useParams();
  const [userDetails, setUserDetails] = useState<UserProps>({} as UserProps);

  const getUserDetailsFetch = useCallback(() => {
    const userDetailsFetch = getUserDetails(params.id as string);
    const userImage = getUserImage(params.id as string);
    const userRating = getUserRating(params.id as string);
    const userReviews = getUserReviews(params.id as string);
    Promise.allSettled([
      userDetailsFetch,
      userImage,
      userRating,
      userReviews,
    ]).then(([userResponse, imageResponse, ratingResponse, reviewResponse]) => {
      if (
        userResponse.status === "fulfilled" &&
        imageResponse.status === "fulfilled" &&
        ratingResponse.status === "fulfilled" &&
        reviewResponse.status === "fulfilled"
      ) {
        const userInfo = { ...userResponse.value.data };
        userInfo.phoneNumber = userInfo?.phoneNumber
          ? userInfo.phoneNumber
          : "";
        userInfo.birthday = userInfo?.birthday ? userInfo.birthday : "";
        userInfo.image = imageResponse.value.data;
        userInfo.rating = ratingResponse.value.data;
        userInfo.reviews = reviewResponse.value.data;
        setUserDetails(() => userInfo);
      }
    });
  }, [params.id]);

  useMemo(() => {
    if (params.id) {
      getUserDetailsFetch();
    }
  }, [getUserDetailsFetch, params.id]);

  const renderUserDetails = (): JSX.Element => {
    if (Object.keys(userDetails).length) {
      return <UserDetails userDetails={userDetails} />;
    }
    return <></>;
  };

  return renderUserDetails();
};

export default UserDetailsManager;
