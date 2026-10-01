--霞烈妖魔谭 火取语
local s,id,o=GetID()
function s.initial_effect(c)
	--①：场上有不死族超量怪兽存在的场合才能发动。进行1只超量怪兽的超量召唤。那之后，把这张卡作为那只怪兽的超量素材
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.xyzcon)
	e1:SetTarget(s.xyztg)
	e1:SetOperation(s.xyzop)
	c:RegisterEffect(e1)
	--①：只要从场上发动的这张卡在魔法陷阱区域表侧表示存在，对手场上的表侧表示的卡的效果无效化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_ONFIELD)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	--②：这张卡从手卡送去墓地的场合或者超量素材的这张卡为让超量怪兽的效果发动而被取除送去墓地的场合才能发动。自己卡组·墓地的1张「火取」魔法·陷阱卡在自己场上盖放
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
--场上的不死族超量怪兽
function s.confilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_XYZ)
end
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.xyzfilter(c)
	return c:IsXyzSummonable(nil)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	Duel.XyzSummon(tp,tc,nil)
	--那之后，把这张卡作为那只怪兽的超量素材
	if tc and c:IsRelateToEffect(e) and c:IsCanOverlay() then
		c:CancelToGrave()
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
--②：自己卡组·墓地的「火取」魔法·陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x37c0) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_HAND) then return true end
	return c:IsPreviousLocation(LOCATION_OVERLAY) and c:IsReason(REASON_COST)
		and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
