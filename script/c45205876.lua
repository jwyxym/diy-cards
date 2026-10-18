-- 借刀杀人 (ID: 45205876)
local s,id,o=GetID()
function s.initial_effect(c)
	-- ①：以对方场上 1 只怪兽为对象才能发动。对方从以下效果选 1 个给自己适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_SUMMON+TIMING_SPSUMMON+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- 目标过滤与前置合法性检查：确保选取的对象至少存在 1 个可执行的分支
function s.target_filter(c,e,tp)
	return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0
		or not c:IsHasEffect(EFFECT_CANNOT_REMOVE)
		or (Duel.GetLocationCount(tp,LOCATION_MZONE,1-tp,LOCATION_REASON_CONTROL)>0 and not c:IsHasEffect(EFFECT_CANNOT_CHANGE_CONTROL))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.target_filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.target_filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.target_filter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
end

-- 效果结算处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()

	-- 1. 动态检测当前时点各分支的可执行性
	-- 分支 1：对方手牌数 > 0
	local b1=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0
	-- 分支 2：怪兽仍存活关联且未被物理禁止除外（以 REASON_RULE 穿透全抗）
	local b2=tc and tc:IsRelateToEffect(e) and not tc:IsHasEffect(EFFECT_CANNOT_REMOVE)
	-- 分支 3：怪兽仍存活关联、己方场上有空位、且未被施加“控制权不能变更”的锁死效果
	local b3=tc and tc:IsRelateToEffect(e) and not tc:IsHasEffect(EFFECT_CANNOT_CHANGE_CONTROL)
		and Duel.GetLocationCount(tp,LOCATION_MZONE,1-tp,LOCATION_REASON_CONTROL)>0

	-- 若所有分支均不满足，则处理终止
	if not b1 and not b2 and not b3 then return end

	-- 2. 动态生成供对方选择的合法菜单
	local op_table={}
	local opt_ids={}
	if b1 then
		table.insert(op_table,aux.Stringid(id,1)) -- 交付手卡
		table.insert(opt_ids,1)
	end
	if b2 then
		table.insert(op_table,aux.Stringid(id,2)) -- 里侧除外
		table.insert(opt_ids,2)
	end
	if b3 then
		table.insert(op_table,aux.Stringid(id,3)) -- 移交控制权
		table.insert(opt_ids,3)
	end

	-- 3. 由对方玩家（1-tp）进行分支抉择
	local sel=Duel.SelectOption(1-tp,table.unpack(op_table))
	local choice=opt_ids[sel+1]

	-- 分支 1 结算：对方选自身 1 张手卡交给自己
	if choice==1 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
		local hg=Duel.SelectMatchingCard(1-tp,nil,1-tp,LOCATION_HAND,0,1,1,nil)
		if #hg>0 then
			Duel.ConfirmCards(tp,hg)
			Duel.SendtoHand(hg,tp,REASON_EFFECT)
		end

	-- 分支 2 结算：对方必须把该怪兽里侧除外（以 REASON_RULE 穿透全抗）
	elseif choice==2 then
		Duel.Remove(tc,POS_FACEDOWN,REASON_RULE,1-tp)

	-- 分支 3 结算：对方必须把该怪兽控制权移给自己（彻底穿透究极猎鹰等全抗）
	elseif choice==3 then
		if tc:IsControler(1-tp) and Duel.GetLocationCount(tp,LOCATION_MZONE,1-tp,LOCATION_REASON_CONTROL)>0 then
			-- 先通过标准接口尝试获取控制权（返回值 <= 0 说明因全抗等原因失败）
			if Duel.GetControl(tc,tp,0,0)<=0 then
				-- 若因全抗（如究极猎鹰、起翼叛逆猎鹰）失败，执行规则级接管：
				-- 1. 以怪兽自身（tc）为 Owner 注册无视效果免疫的控制权效果（避免随魔法卡进墓而失效）
				local e1=Effect.CreateEffect(tc)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_CONTROL)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetValue(tp)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				tc:RegisterEffect(e1,true)

				-- 2. 执行底层强制位移至己方怪兽区
				Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,tc:GetPosition(),true)
			end
		end
	end
end