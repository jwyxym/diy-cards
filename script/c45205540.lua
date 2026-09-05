--山铜结界相关卡
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,48179391) -- 山铜结界
	
	--①效果：自己场上没有怪兽或者自己场上有「山铜结界」的场合才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	--②效果：自己的主要阶段才能发动。从自己的手卡·墓地·除外状态把1张「山铜结界」在自己场上表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.placetg)
	e2:SetOperation(s.placeop)
	c:RegisterEffect(e2)
	
	--③效果：自己·对方的回合，把自己手卡·场上的1张卡送去墓地才能发动。选对方场上·墓地各1张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e3:SetCountLimit(1,id+200)
	e3:SetCost(s.rmcost)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	
	--④效果：这张卡表侧表示存在的场合，自己不能从额外卡组把怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(s.splimit)
	c:RegisterEffect(e4)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		or Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,48179391)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.placefilter(c)
	return c:IsCode(48179391)
end

function s.placetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local b1=Duel.GetLocationCount(tp,LOCATION_FZONE)>0
			and Duel.IsExistingMatchingCard(s.placefilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.placefilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		return b1 or b2
	end
	Duel.SetOperationInfo(0,CATEGORY_PLACE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.placeop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.placefilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g==0 then return end
	local tc=g:GetFirst()
	if tc:IsType(TYPE_FIELD) then
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	else
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end

function s.costfilter(c)
	return c:IsAbleToGraveAsCost()
end

function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	g1:Merge(g2)
	if #g1>0 then
		Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
	end
end

function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end

return s
