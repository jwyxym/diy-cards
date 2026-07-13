--[[
本lua的作者为藜奴儿，如果测试出bug请联系QQ：1502939196
未经允许不支持任何人的任何形式的修改，源数。如有需要请联系作者，而不是私自找人代为修改。
本人对于本lua的任何bug修改、源数和适配后来卡片均为免费，并且追诉期无限。

但是如果使用者私自修改了lua，不论是bug修复还是源数效果，本人对此lua都不会再提供任何形式的支持。
一旦发现任何其他人对本lua进行了任何形式的修改，本人首先自愿放弃此lua除必要署名权以外的所有权利，
同时再也会不承担对此lua的任何维护与后续适配，包括但不限于任何形式的bug修复、效果源数。

如果您想要修改此lua，可以先联系本人，本人会在第一时间进行回复。
并且我承诺，若本人在2天内没有回复您，上述注意事项可作废，您可以直接修改此lua，而后续debug与适配仍然由我来进行。

如果您对本lua有任何疑问，请联系本人，本人会在第一时间进行回复。
如果您对本lua有任何建议，请联系本人，本人会在第一时间进行处理。
]]
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,5,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：「冥骸驱轮·路西法」在自己场上只能有1张表侧表示存在。
	c:SetUniqueOnField(1,0,id)
	-- ②：只要这张卡在自己场上表侧表示存在，和这张卡相同纵列的对方场上的卡效果无效化，不能把效果发动。
	--act limit & def position
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.distg)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_ONFIELD)
	e2:SetTarget(s.distg)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e4:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.discon)
	e5:SetOperation(s.disop)
	c:RegisterEffect(e5)
	-- ③：对方把卡的效果发动时，把这张卡1个超量素材取除，以场上1只怪兽为对象才能发动。那只怪兽的位置向那个相邻的怪兽区域移动。那之后，和这相同纵列有卡2张以上存在的场合，可以选择对方场上·墓地1张卡回到卡组底部。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_TODECK)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCountLimit(1,id)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.effcon)
	e6:SetCost(s.effcost)
	e6:SetTarget(s.efftg)
	e6:SetOperation(s.effop)
	c:RegisterEffect(e6)
end
-- ② filter: opponent's field cards in same column
function s.distg(e,c)
	local tp=e:GetHandlerPlayer()
	local hc=e:GetHandler()
	if not hc:IsFaceup() then return false end
	return aux.GetColumn(c,tp)==aux.GetColumn(hc,tp)
end
-- ② chain solving condition
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() then return false end
	local op,loc,seq2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	if bit.band(loc,LOCATION_ONFIELD)==0 then return false end
	if loc&LOCATION_SZONE~=0 and seq2>4 then return false end
	local seq1=aux.MZoneSequence(c:GetSequence())
	seq2=aux.MZoneSequence(seq2)
	return op==1-tp and seq1==4-seq2
end
-- ② chain solving operation
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end
-- ③ condition: opponent activates a card effect
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- ③ cost: detach 1 Xyz material
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ③ target filter: monster in main monster zone with adjacent empty zone
function s.mvfilter(c,tp)
	local seq=c:GetSequence()
	local p=c:GetControler()
	if seq==5 then return Duel.CheckLocation(p,LOCATION_MZONE,1) end
	if seq==6 then return Duel.CheckLocation(p,LOCATION_MZONE,3) end
	return (5>seq and seq>0 and Duel.CheckLocation(p,LOCATION_MZONE,seq-1))
		or (seq<4 and Duel.CheckLocation(p,LOCATION_MZONE,seq+1))
end
-- ③ target
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.mvfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.mvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local g=Duel.SelectTarget(tp,s.mvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
end
-- ③ operation
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local seq=tc:GetSequence()
	local p=tc:GetControler()
	local flag=0
	if 5>seq and seq>0 and Duel.CheckLocation(p,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
	if seq<4 and Duel.CheckLocation(p,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
	if seq==5 then flag=flag|(1<<1) end
	if seq==6 then flag=flag|(1<<3) end

	if flag==0 then return end
	if p~=tp then flag=flag<<16 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local s2=Duel.SelectField(tp,1,LOCATION_MZONE,LOCATION_MZONE,~flag)
	if p~=tp then s2=s2>>16 end
	local nseq=math.log(s2,2)
	Duel.MoveSequence(tc,nseq)
	local c=e:GetHandler()
	if tc:GetColumnGroupCount()+1>=2 then
		local sg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sc=sg:Select(tp,1,1,nil):GetFirst()
			Duel.HintSelection(Group.FromCards(sc),true)
			Duel.SendtoDeck(sc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
