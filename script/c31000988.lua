--时空银河觉醒
local s,id,o=GetID()
function s.initial_effect(c)
	--① 从自己的手卡·墓地把1只龙族8星·8阶怪兽特殊召唤。那之后，可以从自己墓地或对方的魔法与陷阱区域把1张卡作为自己场上1只龙族超量怪兽的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--自己场上有「银河眼时空龙」怪兽存在的场合，这张卡的发动从手卡也能用
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
	--② 把墓地的这张卡除外才能发动。进行1只龙族超量怪兽的超量召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x307b)
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and (c:IsLevel(8) or c:IsRank(8)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.matfilter(c)
	return c:IsCanOverlay() and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_SZONE) and c:IsFaceup()))
end
function s.xfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.matfilter),tp,LOCATION_GRAVE,LOCATION_SZONE,nil)
		local xg=Duel.GetMatchingGroup(s.xfilter,tp,LOCATION_MZONE,0,nil)
		if mg:GetCount()>0 and xg:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local sg=mg:Select(tp,1,1,nil)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local xyz=xg:Select(tp,1,1,nil):GetFirst()
			Duel.Overlay(xyz,sg)
		end
	end
end
function s.xyzfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) and c:IsXyzSummonable(nil)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=g:Select(tp,1,1,nil)
		Duel.XyzSummon(tp,tg:GetFirst(),nil)
	end
end
