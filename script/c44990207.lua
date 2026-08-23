--灭世者死亡之翼
local s,id=GetID()
function s.initial_effect(c)
	-- 有「死亡之翼」的卡名记述
	aux.AddCodeList(c,44990201)

	-- 融合召唤：有「死亡之翼」的卡名记述的怪兽×2只以上
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep2(c,s.ffilter,2,127,true)

	-- 融合召唤成功时效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- 素材检查：设置素材种类数到效果标签
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end

-- 融合素材条件
function s.ffilter(c,fc)
	return c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,44990201)
end

-- 素材检查值：返回素材种类数，并存入触发效果标签
function s.valcheck(e,c)
	local ct=c:GetMaterial():GetClassCount(Card.GetCode)
	if ct>4 then ct=4 end
	e:GetLabelObject():SetLabel(ct)
	return ct
end

-- 效果条件：融合召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

-- 效果目标：读取素材种类数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	if chk==0 then return ct>0 end
end

-- 墓地特召过滤
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,44990201)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- 对方场上魔法·陷阱卡过滤
function s.mtfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

-- 对方场上怪兽过滤
function s.atkfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(0)
end

-- 效果处理：重复选择（最多4次）
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if ct<=0 then return end
	for i=1,ct do
		local b1 = c:IsRelateToChain() and c:IsFaceup() and c:IsType(TYPE_MONSTER)
		local b2 = Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil)
		local b3 = Duel.IsExistingMatchingCard(s.mtfilter,tp,0,LOCATION_SZONE,1,nil)
		local b4 = Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		local b5 = i>1

		if not b1 and not b2 and not b3 and not b4 then break end

		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},
			{b2,aux.Stringid(id,2),2},
			{b3,aux.Stringid(id,3),3},
			{b4,aux.Stringid(id,4),4},
			{b5,aux.Stringid(id,5),5})

		if i>1 and op~=5 then
			Duel.BreakEffect()
		end

		if op==1 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			e1:SetValue(200)
			c:RegisterEffect(e1)
		elseif op==2 then
			local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil)
			if #g>0 then
				local maxatk = -1
				local maxg = Group.CreateGroup()
				for tc in aux.Next(g) do
					local atk = tc:GetAttack()
					if atk > maxatk then
						maxatk = atk
						maxg = Group.FromCards(tc)
					elseif atk == maxatk then
						maxg:AddCard(tc)
					end
				end
				if maxatk >= 0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
					local sg = maxg:Select(tp,1,1,nil)
					Duel.Destroy(sg,REASON_EFFECT)
				end
			end
		elseif op==3 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			local g=Duel.SelectMatchingCard(tp,s.mtfilter,tp,0,LOCATION_SZONE,1,1,nil)
			if #g>0 then
				Duel.HintSelection(g)
				Duel.SendtoHand(g,nil,REASON_EFFECT)
			end
		elseif op==4 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif op==5 then
			break
		end
	end
end