-- 忘川水母
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Xyz 召唤手续：水族·水属性4星怪兽×2，也可重叠在水族·水属性超量怪兽上超量召唤
	aux.AddXyzProcedure(c,s.matfilter,4,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)

	-- ①：拔 1 素材，结束阶段盖放「渊狱」魔陷
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	-- ②：作为素材赋予效果：对方不能解放，不能作为融合·同调·超量·连接素材
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetCondition(s.xyzcon)
	e2:SetValue(s.releaselimit)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	local e6=e2:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	local e7=e2:Clone()
	e7:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e7:SetValue(1)
	c:RegisterEffect(e7)
end

-- 正规素材过滤：水族·水属性 4 星
function s.matfilter(c)
	return c:IsRace(RACE_AQUA) and c:IsAttribute(ATTRIBUTE_WATER)
end

-- 重叠召唤过滤：水族·水属性超量怪兽
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ)
end

-- 重叠召唤 1 回合 1 次及取除素材代价
function s.xyzop(e,tp,chk,mc)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and mc:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	mc:RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- ①效果：Cost / Target / Operation
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.setfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xd84) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.setop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.SSet(tp,tc)
	end
end

-- ②效果：素材赋予判断（目标超量怪兽需为水族·水属性）
function s.xyzcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsRace(RACE_AQUA) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ)
end

-- 仅限制对方玩家解放
function s.releaselimit(e,re,rp)
	return rp==1-e:GetHandlerPlayer()
end