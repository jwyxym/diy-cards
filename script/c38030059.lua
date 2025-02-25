local cm,m=GetID()

function cm.initial_effect(c)
	-- 效果①：丢弃，送墓
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,m)
	e1:SetCost(cm.cost1)
	e1:SetTarget(cm.target1)
	e1:SetOperation(cm.operation1)
	c:RegisterEffect(e1)
	-- 效果②：除外，特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,m+1)
	e2:SetTarget(cm.target2)
	e2:SetOperation(cm.operation2)
	c:RegisterEffect(e2)
end

-- 效果①：丢弃
function cm.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

-- 效果①：目标
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

-- 效果①：操作
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cm.filter1,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

-- 效果①：4星以下的恶魔族怪兽筛选
function cm.filter1(c)
	return c:IsRace(RACE_FIEND) and c:IsLevelBelow(4) and c:IsAbleToGrave()
end

-- 效果②：目标
function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(cm.filter2,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler():GetLevel(),e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,cm.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler():GetLevel(),e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②：调整以外的8星暗属性恶魔族同调怪兽筛选
function cm.filter2(c,ev,e,tp)
	local lv=c:GetLevel()+ev
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(8)
		and c:IsType(TYPE_SYNCHRO) and not c:IsType(TYPE_TUNER) and Duel.IsExistingMatchingCard(cm.filter3,tp,LOCATION_EXTRA,0,1,nil,lv,e,tp)
end

-- 效果②：暗属性恶魔族同调怪兽筛选
function cm.filter3(c,lv,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)
		and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
-- 效果②：操作
function cm.operation2(e,tp,eg,ep,ev,re,r,rp)	   
		local tc=Duel.GetFirstTarget()
		local lv=tc:GetLevel()+e:GetHandler():GetLevel()
		local g=Group.CreateGroup()
		g:AddCard(tc)
		g:AddCard(e:GetHandler())
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g2=Duel.SelectMatchingCard(tp,cm.filter3,tp,LOCATION_EXTRA,0,1,1,nil,lv,e,tp)
			if #g2>0 then
				Duel.SpecialSummon(g2,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
			end
			-- 限制特殊召唤
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetTarget(cm.splimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
	end
end


-- 效果②：限制特殊召唤
function cm.splimit(e,c)
	return not (c:IsRace(RACE_FIEND) and c:IsType(TYPE_SYNCHRO))
end
