import React from "react";

import { useLocation, useNavigate } from "react-router";

import { ReactComponent as ApproveIcon } from "../../../assets/unverifiedButtonIcons/approve-icon.svg";
import { ReactComponent as RejectIcon } from "../../../assets/unverifiedButtonIcons/reject-icon.svg";
import UserInfoCardComponent from "../../../components/UsersComponents/UserInfoCardComponent/UserInfoCardComponent";
import UserReviewsCardComponent from "../../../components/UsersComponents/UserReviewsCardComponent/UserReviewsCardComponent";
import {
  UserProps,
  deleteUser,
  verifyUser,
} from "../../../Controllers/UserControllers/UsersApi";

import styles from "./users.module.scss";

interface UserDetailsProps {
  userDetails: UserProps;
}

const UserDetails: React.FC<UserDetailsProps> = ({
  userDetails,
}): JSX.Element => {
  const navigate = useNavigate();
  const { state } = useLocation();
  const { verified } = userDetails;
  const { isVolunteer } = state;
  const onApprove = (): void => {
    verifyUser(userDetails)
      .then(() => {
        window.alert("User updated.");
        navigate(isVolunteer ? "/volunteers" : "/users");
      })
      .catch(({ response }) => {
        window.alert(response.data.error.message);
      });
  };

  const onDelete = (): void => {
    deleteUser(userDetails)
      .then(() => {
        window.alert("User deleted");
        navigate(isVolunteer ? "/volunteers" : "/users");
      })
      .catch(({ response }) => {
        window.alert(response.data.error.message);
      });
  };

  const approveRejectButtons = (): JSX.Element => {
    if (verified) {
      return <></>;
    }
    return (
      <div className={styles.buttonContainerDiv}>
        <div className={styles.acceptButtonStyle} onClick={() => onApprove()}>
          <ApproveIcon className={styles.buttonIconStyle} />
          Approve
        </div>
        <div className={styles.rejectButtonStyle} onClick={() => onDelete()}>
          <RejectIcon className={styles.buttonIconStyle} />
          Reject
        </div>
      </div>
    );
  };

  const renderBreadCrumb = (): JSX.Element => (
    <div className={styles.headerContainerStyle}>
      <div className={styles.breadcrumbContainerStyle}>
        <div
          className={styles.breadcrumbActionStyle}
          onClick={(e) => {
            e.preventDefault();
            navigate(isVolunteer ? "/volunteers" : "/users");
          }}
        >
          {isVolunteer ? "Volunteers" : "Users"}
        </div>
        <div className={styles.breadcrumbCurrentStyle}>
          {" "}
          / {isVolunteer ? "Volunteer" : "User"} Profile
        </div>
      </div>
      {approveRejectButtons()}
    </div>
  );

  return (
    <>
      {renderBreadCrumb()}
      <UserInfoCardComponent
        userDetails={userDetails}
        isVolunteer={isVolunteer}
      />
      <UserReviewsCardComponent
        userDetails={userDetails}
        isVolunteer={isVolunteer}
      />
    </>
  );
};

export default UserDetails;
