import React, { useCallback, useEffect, useState } from "react";

import { CCard, CCardBody } from "@coreui/react";
import { ColumnFilterValue } from "@coreui/react-pro/src/components/smart-table/types";

import ContentTableComponent from "../../../components/ContentComponents/ContentTableComponent/ContentTableComponent";
import {
  ContentProps,
  getContentList,
} from "../../../Controllers/ContentController/ContentApi";

import styles from "./contentManagement.module.scss";

const ContentManagement: React.FC = (): JSX.Element => {
  const [contentList, setContentList] = useState<ContentProps[]>([]);
  const [pagination, setPagination] = useState<{
    limit: number;
    offset: number;
    orderBy: string;
    type?: string;
    filter: ColumnFilterValue;
  }>({
    limit: 10,
    offset: 0,
    orderBy: "id asc",
    type: "news",
    filter: {},
  });

  const contentListFetch = useCallback(() => {
    getContentList(pagination)
      .then(({ data }) => {
        const _data = data.map((obj) => ({
          ...obj,
          title: obj.title ? obj.title : "",
          subject: obj.subject ? obj.subject : "",
          _props: { className: styles.tableRowStyle },
        }));
        setContentList(_data);
      })
      .catch(({ response }) => {
        window.alert(response.data.error.message);
      });
  }, [pagination]);

  useEffect(() => {
    contentListFetch();
  }, [contentListFetch]);

  // const handleContentDropdownTypeSelection = (
  //   event: React.MouseEvent<HTMLDivElement, MouseEvent>,
  //   value: string
  // ): void => {
  //   event.preventDefault();
  //   setPagination((currentValues) => ({
  //     ...currentValues,
  //     type: value,
  //   }));
  // };

  // const renderContentTypeSelection = (): JSX.Element => (
  //   <div className={styles.eventsNewsContainerDiv}>
  //     <div
  //       className={
  //         pagination.type === "event"
  //           ? styles.activeEventsButton
  //           : styles.eventsButton
  //       }
  //       onClick={(e) => {
  //         handleContentDropdownTypeSelection(e, "event");
  //       }}
  //     >
  //       Events
  //     </div>
  //     <div
  //       className={
  //         pagination.type === "news"
  //           ? styles.activeNewsButton
  //           : styles.newsButton
  //       }
  //       onClick={(e) => {
  //         handleContentDropdownTypeSelection(e, "news");
  //       }}
  //     >
  //       News
  //     </div>
  //   </div>
  // );

  return (
    <CCard className={styles.containingCard}>
      <CCardBody className={styles.containingCardBody}>
        <div className={styles.pageTitleContainerDiv}>
          <div className={styles.pageTitle}>News</div>
          {/* <div className={styles.dropdownDivStyle}>
            {renderContentTypeSelection()}
          </div> */}
        </div>

        <div className={styles.tableDiv}>
          <ContentTableComponent
            tableData={contentList}
            pagination={pagination}
            setPagination={setPagination}
          />
        </div>
      </CCardBody>
    </CCard>
  );
};

export default ContentManagement;
