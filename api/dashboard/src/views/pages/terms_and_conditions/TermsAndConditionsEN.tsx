import React from "react";

import styles from "./termsAndConditions.module.scss";

const TermsAndConditionsEN = (): JSX.Element => {
  return (
    <div style={{ height: "100%", overflow: "auto" }}>
      <div className={styles.title}>Terms and Conditions - Ajuda+</div>
      <div>
        These Terms and Conditions (&quot;Agreement&quot;) govern your use of
        the Ajuda+ mobile application (&quot;App&quot;) developed for Voxpop by
        mobinteg - Soluções Empresariais de Mobilidade, Lda
        (&quot;Developer&quot;) and co-financed by Câmara Municipal de Lisboa
        and the European Regional Development Fund through the European Urban
        Initiative (&quot;Funders&quot;). By accessing or using the Ajuda+ App,
        you agree to be bound by this Agreement.
      </div>
      <ol>
        <li>Acceptance of Terms</li>
        <div>
          By using the Ajuda+ App, you affirm that you are at least 18 years old
          and capable of entering into a legally binding agreement. If you do
          not agree to these Terms and Conditions, you must not use the Ajuda+
          App.
        </div>
        <li>Description of Ajuda+</li>
        <div>
          Ajuda+ is a mobile application available for download on Google Play
          and Apple Store. The App aims to match elders living in Lisbon with a
          network of volunteers who offer assistance with day-to-day activities
          and chores. The services provided through the App are solely for the
          purpose of facilitating connections between users and volunteers.
        </div>
        <li>Volunteer Services</li>
        <div>
          The Ajuda+ App enables volunteers to offer their services to elders
          who require assistance. Volunteers are solely responsible for the
          services they provide, and Ajuda+ does not guarantee the availability
          or quality of any volunteer services. Users of the App understand and
          acknowledge that Ajuda+ is not responsible for any actions or
          omissions of the volunteers.
        </div>
        <li>User Obligations</li>
        <div>
          As a user of the Ajuda+ App, you agree to:
          <ol type="a">
            <li>
              Provide accurate and complete information during the registration
              process.
            </li>
            <li>
              Maintain the confidentiality of your account credentials and be
              solely responsible for any activities that occur under your
              account.
            </li>
            <li>
              Use the App solely for its intended purpose and in compliance with
              applicable laws and regulations.
            </li>
            <li>
              Treat volunteers with respect and adhere to any guidelines or
              instructions provided by Ajuda+.
            </li>
          </ol>
        </div>
        <li>Limitation of Liability</li>
        <div>
          Ajuda+, Developer, and Funders shall not be liable for any direct,
          indirect, incidental, special, or consequential damages arising out of
          or in connection with the use of the Ajuda+ App. This includes but is
          not limited to damages for loss of profits, goodwill, data, or other
          intangible losses.
        </div>
        <li>Privacy and Data Protection</li>
        <div>
          Ajuda+ respects your privacy and handles personal information in
          accordance with applicable data protection laws. By using the App, you
          consent to the collection, use, and disclosure of your personal
          information as described in the Privacy Policy available on the Ajuda+
          website.
        </div>
        <li>Intellectual Property Rights</li>
        <div>
          All intellectual property rights related to the Ajuda+ App, including
          but not limited to trademarks, copyrights, and trade secrets, are
          owned by the developer or its licensors. Users may not reproduce,
          modify, distribute, or create derivative works of the App without
          prior written permission from the respective rights holder.
        </div>
        <li>Modifications to the Agreement</li>
        <div>
          Ajuda+ reserves the right to modify or amend this Agreement at any
          time. Any changes will be effective immediately upon posting the
          revised Agreement on the Ajuda+ website or within the App. Your
          continued use of the App after the modifications constitute your
          acceptance of the revised Agreement.
        </div>
        <li>Termination</li>
        <div>
          Ajuda+ may suspend or terminate your access to the App at any time
          without prior notice for any reason, including but not limited to a
          violation of this Agreement.
        </div>
        <li>Governing Law and Jurisdiction</li>
        <div>
          This Agreement shall be governed by and construed in accordance with
          the laws of Portugal. Any disputes arising out of or in connection
          with this Agreement shall be subject to the exclusive jurisdiction of
          the courts of Lisbon.
        </div>
        <li>Entire Agreement</li>
        <div>
          This Agreement constitutes the entire agreement between you and Ajuda+
          regarding the use of the App and supersedes any prior agreements,
          understandings, or representations.
        </div>
      </ol>

      <div>
        If you have any questions or concerns regarding these Terms and
        Conditions, please contact us at ajudamais.mobinteg@gmail.com
      </div>
    </div>
  );
};

export default TermsAndConditionsEN;
