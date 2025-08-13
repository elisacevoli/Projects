function distance = joint_distance(skeleton,joint_1, joint_2,I,heatmaps)

    joint1 = skeleton(joint_1,:);
    joint2 = skeleton(joint_2,:);

    distance = sqrt((joint2(1) - joint1(1))^2 + (joint2(2) - joint1(2))^2);

end