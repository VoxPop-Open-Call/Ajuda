import React from "react";

import { cisStar } from "@coreui/icons-pro";
import CIcon from "@coreui/icons-react";
import moment from "moment";

import styles from "./commonUtils.module.scss";

export const weekDayMap: { [key: string]: string } = {
  0: "Sunday",
  1: "Monday",
  2: "Tuesday",
  3: "Wednesday",
  4: "Thursday",
  5: "Friday",
  6: "Saturday",
};

export const languageTLAMap: { [key: string]: string } = {
  en: "English",
  es: "Spanish",
  fr: "French",
  pt: "Portuguese",
};

export const capitalizeWord = (word: string): string => {
  const firstLetter = word.charAt(0).toUpperCase();
  const restWord = word.slice(1).toLowerCase();
  return firstLetter + restWord;
};

export const formatTime = (time: string): string => {
  if (!time) {
    return "";
  }
  return moment(time, "HH:mmZ").format("h:mm A");
};

export const renderRatingStars = (numberStars: number): JSX.Element[] => {
  const starArray = [];
  for (let i = 0; i < 5; i++) {
    starArray.push(
      <CIcon
        icon={cisStar}
        className={
          i < numberStars
            ? styles.ratingIconStyle
            : styles.disableRatingIconStyle
        }
      />
    );
  }
  return starArray;
};
