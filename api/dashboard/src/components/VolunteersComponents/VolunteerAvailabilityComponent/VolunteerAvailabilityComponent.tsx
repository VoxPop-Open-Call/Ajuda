import React from "react";

import { formatTime, weekDayMap } from "../../../utils/commonUtils";

import styles from "./volunteerAvailabilityComponent.module.scss";

interface VolunteerAvailabilityComponentProps {
  userAvailability: {
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
}

const VolunteerAvailabilityComponent: React.FC<
  VolunteerAvailabilityComponentProps
> = ({ userAvailability }) => {
  // const { availabilities } = userAvailability;

  // const formatHours = (hourToFormat: string): string => {
  //   const correctHourFormat = hourToFormat.slice(0, -1);
  //   return moment(correctHourFormat, "h:mm a").format("H:mm A");
  // };

  const renderDayAvailability = (): JSX.Element[] => {
    if (!userAvailability?.availabilities?.length) {
      return [<></>];
    }

    return userAvailability.availabilities.map(({ weekDay, start, end }) => (
      <div key={weekDayMap[weekDay]} className={styles.timeEntryContainerDiv}>
        <div className={styles.timeEntryDayStyle}>{weekDayMap[weekDay]}</div>
        <div className={styles.timeEntryTimeStyle}>
          {formatTime(start)} • {formatTime(end)}
        </div>
      </div>
    ));
  };

  return (
    <div className={styles.containerDiv}>
      <div className={styles.titleStyle}>Availability</div>
      <div>{renderDayAvailability()}</div>
    </div>
  );
};

export default VolunteerAvailabilityComponent;
