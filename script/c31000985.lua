--银河龙皇之战
local s,id,o=GetID()
function s.initial_effect(c)
	--① 作为这张卡的发动时的效果处理，可以把自己的墓地·除外状态的1只「银河眼」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--② 自己场上的龙族超量怪兽不能解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.relfilter)
	c:RegisterEffect(e2)
	--③ 自己场上有「银河眼」怪兽存在的场合，以对方场上1张卡为对象才能发动（对方场上有龙族怪兽存在的场合，对方不能对应这个效果的发动把效果发动）。那张卡破坏并除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x107b) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local cg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	if #cg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=cg:Select(tp,1,1,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.relfilter(e,c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ)
end
function s.gfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107b)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.gfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.dfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	if Duel.IsExistingMatchingCard(s.dfilter,1-tp,LOCATION_MZONE,0,1,nil) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,ep,tp)
	return tp==ep
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT,LOCATION_REMOVED)
	end
end
