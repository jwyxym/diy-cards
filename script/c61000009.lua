--侠烈之魔妖 火取魔
local s,id,o=GetID()
function s.initial_effect(c)
	--超量召唤。也可把2张手卡丢弃，在自己场上的「火取」怪兽上面重叠来超量召唤
	aux.AddXyzProcedure(c,nil,6,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
	--自己对「侠烈之魔妖 火取魔」1回合只能有1次特殊召唤
	c:SetSPSummonOnce(id)
	--①：这张卡特殊召唤的场合才能发动。选自己·对方的墓地·除外状态各最多1张卡重叠作为超量素材
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.mttg)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	--②：1回合1次，把这张卡的超量素材全部取除才能发动。检索·加入手卡并丢弃1张手卡，取除3个以上的场合再抽1张
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES_SELF)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
--在自己场上的「火取」怪兽上面重叠来超量召唤
function s.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x37c0)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD,nil)
end
function s.mtfilter(c)
	return c:IsCanOverlay()
end
function s.mtcount(c,p,loc)
	return c:GetControler()==p and c:IsLocation(loc)
end
--自己·对方的墓地·除外状态各最多1张
function s.mtcheck(g)
	for p=0,1 do
		if g:FilterCount(s.mtcount,nil,p,LOCATION_GRAVE)>1 then return false end
		if g:FilterCount(s.mtcount,nil,p,LOCATION_REMOVED)>1 then return false end
	end
	return true
end
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	if g:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local sg=g:SelectSubGroup(tp,s.mtcheck,false,1,4)
	if sg and sg:GetCount()>0 then
		Duel.HintSelection(sg)
		Duel.Overlay(c,sg)
	end
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local ct=c:GetOverlayCount()
	e:SetLabel(ct)
	c:RemoveOverlayCard(tp,ct,ct,REASON_COST)
end
--守备力0的不死族·炎属性怪兽或者「火取」魔法·陷阱卡
function s.thfilter(c)
	return c:IsAbleToHand() and ((c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ZOMBIE) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsDefense(0))
		or (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x37c0)))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	local cat=CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES_SELF
	if e:GetLabel()>=3 then cat=cat+CATEGORY_DRAW end
	e:SetCategory(cat)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
	if e:GetLabel()>=3 then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD,nil)
	end
	if e:GetLabel()>=3 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
