import React from "react";

import styles from "./requestTypeToggleComponent.module.scss";

interface assigmentTypeToggleComponentProps {
  taskStatus: { isAll: boolean; isComplete: boolean; isUpcoming: boolean };
  setTaskStatus: React.Dispatch<
    React.SetStateAction<{
      isAll: boolean;
      isComplete: boolean;
      isUpcoming: boolean;
    }>
  >;
}

const AssignmentTypeToggleComponent: React.FC<
  assigmentTypeToggleComponentProps
> = ({
  taskStatus,
  setTaskStatus,
}: assigmentTypeToggleComponentProps): JSX.Element => {
  const handleToggleChanges = (fieldName: keyof typeof taskStatus): void => {
    const newTaskStatus = {
      isAll: false,
      isComplete: false,
      isUpcoming: false,
    };
    newTaskStatus[fieldName] = !newTaskStatus[fieldName];
    setTaskStatus(() => newTaskStatus);
  };

  return (
    <div className={styles.togglerDiv}>
      <div
        className={
          taskStatus.isAll
            ? styles.completeActiveButtonStyle
            : styles.completeButtonStyle
        }
        onClick={() => handleToggleChanges("isAll")}
      >
        All
      </div>
      <div
        className={
          taskStatus.isUpcoming
            ? styles.upcomingActiveButtonStyle
            : styles.upcomingButtonStyle
        }
        onClick={() => handleToggleChanges("isUpcoming")}
      >
        Upcoming
      </div>
      <div
        className={
          taskStatus.isComplete
            ? styles.completeActiveButtonStyle
            : styles.completeButtonStyle
        }
        onClick={() => handleToggleChanges("isComplete")}
      >
        Completed
      </div>
    </div>
  );
};

export default AssignmentTypeToggleComponent;
