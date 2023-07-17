import React from "react";

import { cisStar } from "@coreui/icons-pro";
import CIcon from "@coreui/icons-react";
import moment from "moment";

import UserErrorImage from "../../../assets/userIcons/placeholder.svg";
import {
  UserImageProps,
  UserRatingProps,
} from "../../../Controllers/UserControllers/UsersApi";

import styles from "./userContactCardComponent.module.scss";

interface UserContactCardComponentProps {
  image: UserImageProps;
  name: string;
  phoneNumber: string;
  birthday: string;
  email: string;
  createdAt: Date;
  rating: UserRatingProps;
  isVolunteer: boolean;
}

const UserContactCardComponent: React.FC<UserContactCardComponentProps> = ({
  image,
  name,
  phoneNumber,
  birthday,
  email,
  createdAt,
  rating,
  isVolunteer,
}) => {
  const renderVolunteerRating = (): JSX.Element => {
    if (isVolunteer) {
      return (
        <div
          className={
            rating?.averageRating
              ? styles.ratingContainerDivStyle
              : styles.disableRatingContainerDivStyle
          }
        >
          <CIcon
            icon={cisStar}
            className={
              rating?.averageRating
                ? styles.ratingIconStyle
                : styles.disableRatingIconStyle
            }
          />
          {rating?.averageRating ? rating?.averageRating : "0.0"}
        </div>
      );
    }
    return <></>;
  };

  const renderVolunteerReviewsString = (): string =>
    isVolunteer ? "reviews" : "requests";

  return (
    <div className={styles.userPersonalInfoDiv}>
      <div className={styles.imageContainerDiv}>
        <img
          src={image.url}
          className={styles.imageStyle}
          onError={(e) => {
            const target = e.target as HTMLImageElement;
            target.src = UserErrorImage;
          }}
        />
      </div>
      <div>
        <div className={styles.nameStyle}>{name}</div>
        <div className={styles.userContactsContainerDiv}>
          <div className={styles.userContactsFieldContainerDiv}>
            <div className={styles.userContactsFieldStyle}>Mobile Phone</div>
            <div className={styles.userContactsFieldStyle}>Date of Birth</div>
            <div className={styles.userContactsFieldStyle}>Email</div>
          </div>
          <div>
            <div className={styles.userContactsStyle}>{phoneNumber}</div>
            <div className={styles.userContactsStyle}>{birthday}</div>
            <div className={styles.userContactsStyle}>{email}</div>
          </div>
        </div>
      </div>
      <div className={styles.ratingContainerDiv}>
        <div className={styles.ratingCreationContainerDiv}>
          <div className={styles.userContactsCreationFieldStyle}>
            Date Joined
          </div>
          <div className={styles.userContactsStyle}>
            {moment(createdAt).utc().format("DD MMM, YYYY").toString()}
          </div>
        </div>
        <div className={styles.ratingCreationContainerDiv}>
          {renderVolunteerRating()}
          <div
            className={
              rating.reviewCount
                ? styles.reviewsCounterStyle
                : styles.disableReviewsCounterStyle
            }
          >
            ({rating.reviewCount} {renderVolunteerReviewsString()})
          </div>
        </div>
      </div>
    </div>
  );
};

export default UserContactCardComponent;
