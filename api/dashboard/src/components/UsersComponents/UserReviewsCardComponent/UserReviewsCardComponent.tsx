import React from "react";

import { cisStar } from "@coreui/icons-pro";
import CIcon from "@coreui/icons-react";
import { CCard, CCardBody } from "@coreui/react";

import { ReactComponent as NoReviewsIcon } from "../../../assets/reviewsCardIcons/candidate-profile-analysis.svg";
import { UserProps } from "../../../Controllers/UserControllers/UsersApi";
import { formatTime, renderRatingStars } from "../../../utils/commonUtils";

import styles from "./userReviewsCardComponent.module.scss";

interface UserReviewsCardComponentProps {
  userDetails: UserProps;
  isVolunteer: boolean;
}
const UserReviewsCardComponent: React.FC<UserReviewsCardComponentProps> = ({
  userDetails,
  isVolunteer,
}) => {
  const { reviews } = userDetails;

  const renderReviewTitle = (): string => (isVolunteer ? "Reviews" : "History");

  const renderVolunteerReviewsString = (): string =>
    isVolunteer ? "reviews" : "requests";

  const renderAverageRating = (): JSX.Element => {
    if (isVolunteer) {
      return (
        <div
          className={
            userDetails.rating?.averageRating
              ? styles.ratingContainerDivStyle
              : styles.disableRatingContainerDivStyle
          }
        >
          <CIcon
            icon={cisStar}
            className={
              userDetails.rating?.averageRating
                ? styles.ratingIconStyle
                : styles.disableRatingIconStyle
            }
          />
          {userDetails.rating?.averageRating
            ? userDetails.rating?.averageRating
            : "0.0"}
        </div>
      );
    }
    return <></>;
  };

  // const renderRatingStars = (numberStars: number): JSX.Element[] => {
  //   const starArray = [];
  //   for (let i = 0; i < 5; i++) {
  //     starArray.push(
  //       <CIcon
  //         icon={cisStar}
  //         className={
  //           i < numberStars
  //             ? styles.ratingIconStyle
  //             : styles.disableRatingIconStyle
  //         }
  //       />
  //     );
  //   }
  //   return starArray;
  // };

  const renderUserReviews = (): JSX.Element[] => {
    if (!reviews?.length) {
      return [
        <div key={"No Reviews"} className={styles.noReviewsContainerDiv}>
          <NoReviewsIcon className={styles.noReviewImageStyle} />

          <div className={styles.noReviewTextStyle}>
            There are no {renderVolunteerReviewsString()} for this user yet.
          </div>
        </div>,
      ];
    }
    // task.taskType.code, task.date, task.timeFrom, task.timeTo
    // getUserImage using task.requesterId, getUserDetails using task.requesterId , rating
    // comment
    return reviews.map(({ task, rating, comment }) => (
      <div key={"asdfwaefasdf"} className={styles.reviewEntryDiv}>
        <div className={styles.reviewHeaderContainerDiv}>
          <div className={styles.taskTypeNameStyle}>{task.taskType.code}</div>
          <div className={styles.taskDateStyle}>
            {task.date} • {formatTime(task.timeFrom)} -{" "}
            {formatTime(task.timeTo)}
          </div>
        </div>
        <div className={styles.requesterContainerDiv}>
          <div className={styles.imageContainerDiv}>Image</div>
          <div>
            <div className={styles.requesterNameStyle}>Elizabeth Jackson</div>
            <div>{renderRatingStars(rating)}</div>
          </div>
        </div>
        <div className={styles.commentStyle}>{comment ? comment : ""}</div>
      </div>
    ));
  };

  return (
    <CCard className={styles.cardStyle}>
      <CCardBody className={styles.cardBodyStyle}>
        <div className={styles.titleContainerDiv}>
          <div className={styles.titleStyle}>{renderReviewTitle()}</div>
          <div className={styles.ratingCreationContainerDiv}>
            {renderAverageRating()}
            <div
              className={
                userDetails.rating.reviewCount
                  ? styles.reviewsCounterStyle
                  : styles.disableReviewsCounterStyle
              }
            >
              ({userDetails.rating.reviewCount} {renderVolunteerReviewsString()}
              )
            </div>
          </div>
        </div>
        {renderUserReviews()}
      </CCardBody>
    </CCard>
  );
};

export default UserReviewsCardComponent;
